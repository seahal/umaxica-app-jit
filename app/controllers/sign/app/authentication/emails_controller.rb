module Sign
  module App
    module Authentication
      class EmailsController < ApplicationController
        include ::CloudflareTurnstile

        def new
          render plain: t("sign.app.authentication.email.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          @user_email = UserIdentityEmail.new
        end

        def edit
          render plain: t("sign.app.authentication.email.edit.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          if session[:user_email_authentication].nil?
            redirect_to new_sign_app_authentication_email_path,
                        notice: t("sign.app.authentication.email.edit.session_expired")
          else
            @user_email = UserIdentityEmail.new(address: session[:user_email_authentication]["address"])
          end
        end

        def create
          render plain: t("sign.app.authentication.email.create.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          address_params = params.expect(user_identity_email: [ :address ])
          address = address_params[:address]
          res = cloudflare_turnstile_validation

          if res["success"] && address.present?
            # Check if email exists in database
            existing_email = UserIdentityEmail.find_by(address: address)

            if existing_email.nil?
              @user_email = UserIdentityEmail.new(address: address)
              @user_email.errors.add(:address, t("sign.app.authentication.email.create.email_not_found"))
              render :new, status: :unprocessable_content and return
            end

            @user_email = existing_email

            # Generate OTP
            otp_private_key = ROTP::Base32.random_base32
            otp_count_number = [ Time.now.to_i, SecureRandom.random_number(1 << 64) ].map(&:to_s).join.to_i
            hotp = ROTP::HOTP.new(otp_private_key)
            otp_code = hotp.at(otp_count_number)
            id = SecureRandom.uuid_v7

            # Store in session
            session[:user_email_authentication] = {
              id: id,
              address: @user_email.address,
              otp_private_key: otp_private_key,
              otp_counter: otp_count_number,
              expires_at: 12.minutes.from_now.to_i
            }

            # Send email with OTP
            Email::App::RegistrationMailer.with(
              hotp_token: otp_code,
              email_address: @user_email.address
            ).create.deliver_now

            redirect_to edit_sign_app_authentication_email_path(id),
                        notice: t("sign.app.authentication.email.create.verification_code_sent")
          else
            @user_email = UserIdentityEmail.new(address: address)
            render :new, status: :unprocessable_content
          end
        end

        def update
          render plain: t("sign.app.authentication.email.update.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          token = session[:user_email_authentication]
          if token.nil? || token["expires_at"].to_i <= Time.now.to_i
            redirect_to new_sign_app_authentication_email_path,
                        notice: t("sign.app.authentication.email.edit.session_expired") and return
          end

          @user_email = UserIdentityEmail.new(
            pass_code: update_pass_code_params[:pass_code]
          )

          unless @user_email.valid?
            render :edit, status: :unprocessable_content and return
          end

          hotp = ROTP::HOTP.new(token["otp_private_key"])
          expected_code = hotp.at(token["otp_counter"]).to_s

          if expected_code == @user_email.pass_code
            session[:user_email_authentication] = nil
            redirect_to "/", notice: t("sign.app.authentication.email.update.success")
          else
            @user_email.errors.add(:pass_code, t("sign.app.authentication.email.update.invalid_code"))
            render :edit, status: :unprocessable_content
          end
        end

        private

        def update_pass_code_params
          params.expect(user_identity_email: [ :pass_code ])
        rescue ActionController::ParameterMissing
          {}
        end
      end
    end
  end
end
