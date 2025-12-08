module Sign
  module App
    module Registration
      class EmailsController < ApplicationController
        include ::CloudflareTurnstile
        include ::Redirect

        def new
          render plain: t("sign.app.authentication.email.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          # # to avoid session attack
          session[:user_email_registration] = nil

          # make user email
          @user_email = UserIdentityEmail.new
        end

        def edit
          render plain: t("sign.app.registration.email.edit.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?
          render plain: t("sign.app.registration.email.edit.forbidden_action"),
                 status: :bad_request and return if session[:user_email_registration].nil?

          registration_session = session[:user_email_registration]
          if registration_session && registration_session["id"] == params["id"] && registration_session["expires_at"].to_i > Time.now.to_i
            @user_email = UserIdentityEmail.find_by(id: params["id"]) || UserIdentityEmail.new
          else
            redirect_to new_sign_app_registration_email_path,
                        notice: t("sign.app.registration.email.edit.session_expired")
          end
        end

        def create
          # FIXME: write test code!
          render plain: t("sign.app.authentication.email.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          @user_email = UserIdentityEmail.new(params.expect(user_identity_email: [ :address, :confirm_policy ]))
          res = cloudflare_turnstile_validation
          otp_private_key = ROTP::Base32.random_base32
          otp_count_number = [ Time.now.to_i, SecureRandom.random_number(1 << 64) ].map(&:to_s).join.to_i
          hotp = ROTP::HOTP.new(otp_private_key)
          num = hotp.at(otp_count_number)
          expires_at = 12.minutes.from_now.to_i

          if res["success"] && @user_email.valid?
            # Save email and store OTP in database
            @user_email.save!
            @user_email.store_otp(otp_private_key, otp_count_number, expires_at)

            # Store only the reference ID in session
            session[:user_email_registration] = {
              id: @user_email.id,
              expires_at: expires_at
            }

            # FIXME: use kafka!
            Email::App::RegistrationMailer.with({ hotp_token: num,
                                                  email_address: @user_email.address }).create.deliver_now

            redirect_to edit_sign_app_registration_email_path(@user_email.id), notice: t("sign.app.registration.email.create.verification_code_sent")
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          # FIXME: write test code!
          render plain: t("sign.app.authentication.email.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          registration_session = session[:user_email_registration]
          if registration_session.blank? || registration_session["id"] != params["id"]
            render :edit, status: :unprocessable_content and return
          end

          # Retrieve email record with OTP
          @user_email = UserIdentityEmail.find_by(id: params["id"])
          if @user_email.blank? || @user_email.otp_expired? || registration_session["expires_at"].to_i <= Time.now.to_i
            render :edit, status: :unprocessable_content and return
          end

          # Verify OTP using secure_compare
          submitted_code = params["user_identity_email"]["pass_code"]
          otp_data = @user_email.get_otp
          if otp_data.blank? || submitted_code.blank?
            @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.invalid_code"))
            render :edit, status: :unprocessable_content and return
          end

          # Verify OTP with timing attack protection
          hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
          expected_code = hotp.at(otp_data[:otp_counter]).to_s
          unless ActiveSupport::SecurityUtils.secure_compare(expected_code, submitted_code)
            @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.invalid_code"))
            render :edit, status: :unprocessable_content and return
          end

          # Clear OTP and complete registration
          @user_email.clear_otp
          session[:user_email_registration] = nil
          redirect_to "/", notice: t("sign.app.registration.email.update.success")
        end
      end
    end
  end
end
