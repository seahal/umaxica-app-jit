module Sign
  module App
    module Authentication
      class EmailsController < ApplicationController
        include ::CloudflareTurnstile
        include EmailValidation
        include SecureOtpStorage

        def new
          render plain: t("sign.app.authentication.email.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          @user_email = UserIdentityEmail.new
        end

        def edit
          render plain: t("sign.app.authentication.email.edit.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          otp_id = session[:user_email_authentication_id]
          if otp_id.nil?
            redirect_to new_sign_app_authentication_email_path,
                        notice: t("sign.app.authentication.email.edit.session_expired")
          else
            otp_data = get_otp_secret(otp_id)
            if otp_data.nil?
              redirect_to new_sign_app_authentication_email_path,
                          notice: t("sign.app.authentication.email.edit.session_expired")
            else
              @user_email = UserIdentityEmail.new(address: otp_data[:address])
            end
          end
        end

        def create
          render plain: t("sign.app.authentication.email.create.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          address_params = params.expect(user_identity_email: [ :address ])
          address = address_params[:address]
          res = cloudflare_turnstile_validation

          if res["success"] && address.present?
            # Validate and normalize email
            normalized_address = validate_and_normalize_email(address)
            if normalized_address.nil?
              @user_email = UserIdentityEmail.new(address: address)
              @user_email.errors.add(:address, t("sign.app.authentication.email.create.invalid_format"))
              render :new, status: :unprocessable_content and return
            end

            # Check if email exists in database (with timing attack protection)
            existing_email = find_email_with_timing_protection(normalized_address)

            if existing_email.nil?
              @user_email = UserIdentityEmail.new(address: normalized_address)
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

            # Store OTP secret in Redis (NOT in session/cookie)
            expires_at = 12.minutes.from_now.to_i
            store_otp_secret(id, @user_email.address, otp_private_key, otp_count_number, expires_at)

            # Store only the reference ID in session
            session[:user_email_authentication_id] = id

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

          otp_id = session[:user_email_authentication_id]
          otp_data = get_otp_secret(otp_id) if otp_id.present?

          if otp_data.nil? || otp_data[:expires_at].to_i <= Time.now.to_i
            redirect_to new_sign_app_authentication_email_path,
                        notice: t("sign.app.authentication.email.edit.session_expired") and return
          end

          @user_email = UserIdentityEmail.new(
            pass_code: update_pass_code_params[:pass_code]
          )

          unless @user_email.valid?
            render :edit, status: :unprocessable_content and return
          end

          hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
          expected_code = hotp.at(otp_data[:otp_counter]).to_s

          if expected_code == @user_email.pass_code
            delete_otp_secret(otp_id)
            session[:user_email_authentication_id] = nil
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
