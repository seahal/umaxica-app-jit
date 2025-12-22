module Auth
  module App
    module Registration
      class PasskeysController < ApplicationController
        include ::Redirect

        # todo: verify not logged in
        def new
          @user_telephone = UserIdentityTelephone.new

          # # to avoid session attack
          session[:user_telephone_registration] = nil
        end

        # todo: verify not logged in
        def edit
          render plain: t("auth.app.registration.telephone.edit.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?
          render plain: t("auth.app.registration.telephone.edit.forbidden_action"),
                 status: :bad_request and return if session[:user_telephone_registration].nil?

          registration_session = session[:user_telephone_registration]
          if [ registration_session["id"] == params["id"],
               registration_session["expires_at"].to_i > Time.now.to_i ].all?
            @user_telephone = UserIdentityTelephone.find_by(id: params["id"]) || UserIdentityTelephone.new
          else
            redirect_to new_auth_app_registration_passkey_path,
                        notice: t("auth.app.registration.telephone.edit.session_expired")
          end
        end

        # todo: verify not logged in
        def create
          render plain: t("auth.app.authentication.telephone.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          @user_telephone = UserIdentityTelephone.new(params.expect(user_identity_telephone: [ :number, :confirm_policy,
                                                                                               :confirm_using_mfa ]))

          res = cloudflare_turnstile_validation
          otp_private_key = ROTP::Base32.random_base32
          otp_count_number = [ Time.now.to_i, SecureRandom.random_number(1 << 64) ].map(&:to_s).join.to_i
          hotp = ROTP::HOTP.new(otp_private_key)
          num = hotp.at(otp_count_number)
          expires_at = 12.minutes.from_now.to_i

          if res["success"] && @user_telephone.valid?
            # Save telephone and store OTP in database
            @user_telephone.save!
            @user_telephone.store_otp(otp_private_key, otp_count_number, expires_at)

            # Store only the reference ID and expiry in session
            session[:user_telephone_registration] = {
              id: @user_telephone.id,
              confirm_policy: boolean_value(@user_telephone.confirm_policy),
              confirm_using_mfa: boolean_value(@user_telephone.confirm_using_mfa),
              expires_at: expires_at
            }

            # Send SMS with OTP
            AwsSmsService.send_message(
              to: @user_telephone.number,
              message: "PassCode => #{num}",
              subject: "PassCode => #{num}"
            )

            redirect_to edit_auth_app_registration_passkey_path(@user_telephone.id),
                        notice: t("auth.app.registration.telephone.create.verification_code_sent")
          else
            render :new, status: :unprocessable_content
          end
        end

        # todo: verify not logged in
        def update
          # FIXME: write test code!
          render plain: t("auth.app.authentication.telephone.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          registration_session = session[:user_telephone_registration]
          if registration_session.blank? || registration_session["id"] != params["id"]
            render :edit, status: :unprocessable_content and return
          end

          # Retrieve telephone record with OTP
          @user_telephone = UserIdentityTelephone.find_by(id: params["id"])
          if @user_telephone.blank? || @user_telephone.otp_expired? || registration_session["expires_at"].to_i <= Time.now.to_i
            render :edit, status: :unprocessable_content and return
          end

          # Verify OTP using secure_compare
          submitted_code = params.dig("user_identity_telephone", "pass_code")
          otp_data = @user_telephone.get_otp
          if otp_data.blank? || submitted_code.blank?
            @user_telephone.errors.add(:pass_code, t("auth.app.registration.telephone.update.invalid_code"))
            render :edit, status: :unprocessable_content and return
          end

          # Verify OTP with timing attack protection
          hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
          expected_code = hotp.at(otp_data[:otp_counter]).to_s
          unless ActiveSupport::SecurityUtils.secure_compare(expected_code, submitted_code)
            @user_telephone.increment_attempts!
            @user_telephone.errors.add(:pass_code, t("auth.app.registration.telephone.update.invalid_code"))
            render :edit, status: :unprocessable_content and return
          end

          # Update attributes and clear OTP
          @user_telephone.update!(
            confirm_policy: registration_session.fetch("confirm_policy", true),
            confirm_using_mfa: registration_session.fetch("confirm_using_mfa", true)
          )
          @user_telephone.clear_otp
          session[:user_telephone_registration] = nil
          redirect_to "/", notice: t("auth.app.registration.telephone.update.success")
        end

        private

          def boolean_value(value)
            ActiveModel::Type::Boolean.new.cast(value)
          end
      end
    end
  end
end
