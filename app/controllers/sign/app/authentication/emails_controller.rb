module Sign
  module App
    module Authentication
      class EmailsController < ApplicationController
        include ::CloudflareTurnstile
        include EmailValidation

        def new
          render plain: t("sign.app.authentication.email.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          @user_email = UserIdentityEmail.new
        end

        def edit
          render plain: t("sign.app.authentication.email.edit.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          if session[:user_email_authentication_id].present?
            @user_email = UserIdentityEmail.find_by(id: session[:user_email_authentication_id])
            if @user_email.nil? || @user_email.otp_expired?
              redirect_to new_sign_app_authentication_email_path, notice: t("sign.app.authentication.email.edit.session_expired")
            end
          elsif session[:user_email_authentication_address].present?
            @user_email = UserIdentityEmail.new(address: session[:user_email_authentication_address])
          else
            redirect_to new_sign_app_authentication_email_path, notice: t("sign.app.authentication.email.edit.session_expired")
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

            if existing_email
              # Generate OTP
              otp_private_key = ROTP::Base32.random_base32
              otp_count_number = [ Time.now.to_i, SecureRandom.random_number(1 << 64) ].map(&:to_s).join.to_i
              hotp = ROTP::HOTP.new(otp_private_key)
              otp_code = hotp.at(otp_count_number)
              expires_at = 12.minutes.from_now.to_i

              existing_email.store_otp(otp_private_key, otp_count_number, expires_at)
              session[:user_email_authentication_id] = existing_email.id
              session[:user_email_authentication_address] = nil

              Email::App::RegistrationMailer.with(
                hotp_token: otp_code,
                email_address: existing_email.address
              ).create.deliver_now
            else
              # Dummy work to simulate OTP generation
              ROTP::Base32.random_base32
              ROTP::HOTP.new("dummy").at(0)

              session[:user_email_authentication_id] = nil
              session[:user_email_authentication_address] = normalized_address
            end

            redirect_to edit_sign_app_authentication_email_path,
                        notice: t("sign.app.authentication.email.create.verification_code_sent")
          else
            @user_email = UserIdentityEmail.new(address: address)
            render :new, status: :unprocessable_content
          end
        end

        def update
          render plain: t("sign.app.authentication.email.update.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          if session[:user_email_authentication_id].present?
            @user_email = UserIdentityEmail.find_by(id: session[:user_email_authentication_id])
            if @user_email.nil? || @user_email.otp_expired?
              redirect_to new_sign_app_authentication_email_path, notice: t("sign.app.authentication.email.edit.session_expired") and return
            end
          elsif session[:user_email_authentication_address].present?
            @user_email = UserIdentityEmail.new(address: session[:user_email_authentication_address])
          else
            redirect_to new_sign_app_authentication_email_path, notice: t("sign.app.authentication.email.edit.session_expired") and return
          end

          # Start monotonic timer to protect against timing attacks
          start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          @user_email.pass_code = update_pass_code_params[:pass_code]

          unless @user_email.valid?
            render :edit, status: :unprocessable_content and return
          end

          if session[:user_email_authentication_id].present?
            otp_data = @user_email.get_otp
            if otp_data
              hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
              expected_code = hotp.at(otp_data[:otp_counter]).to_s

              if ActiveSupport::SecurityUtils.secure_compare(expected_code, @user_email.pass_code)
                @user_email.clear_otp
                session[:user_email_authentication_id] = nil
                log_in(@user_email.user)
                ensure_min_elapsed(start_time)
                redirect_to "/", notice: t("sign.app.authentication.email.update.success")
              else
                # Increment attempts first. If not locked yet, present remaining attempts.
                @user_email.increment_attempts!

                if @user_email.locked?
                  @user_email.errors.add(:pass_code, t("sign.app.authentication.email.locked"))
                else
                  remaining = [ 3 - @user_email.otp_attempts_count, 0 ].max
                  # Prefer localized message with attempts interpolation when available
                  @user_email.errors.add(:pass_code, t("sign.app.authentication.email.update.invalid_code", attempts_left: remaining))
                end

                ensure_min_elapsed(start_time)

                render :edit, status: :unprocessable_content
              end
            else
              ensure_min_elapsed(start_time)
              redirect_to new_sign_app_authentication_email_path, notice: t("sign.app.authentication.email.edit.session_expired")
            end
          else
            ActiveSupport::SecurityUtils.secure_compare("000000", @user_email.pass_code)
            @user_email.errors.add(:pass_code, t("sign.app.authentication.email.update.invalid_code"))

            ensure_min_elapsed(start_time)

            render :edit, status: :unprocessable_content
          end
        end

        private

        def update_pass_code_params
          params.expect(user_identity_email: [ :pass_code ])
        rescue ActionController::ParameterMissing
          {}
        end

        def ensure_min_elapsed(start_time, target_seconds = 0.01)
          elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
          remaining = target_seconds - elapsed
          sleep(remaining) if remaining.positive?
        end
      end
    end
  end
end
