module Sign
  module App
    module Authentication
      class EmailsController < ApplicationController
        include ::CloudflareTurnstile
        include EmailValidation
        include ::Redirect

        before_action :ensure_not_logged_in
        before_action :load_user_email, only: %i[edit update]

        def new
          @user_email = UserIdentityEmail.new
        end

        def edit
        end

        def create
          address_params = params.expect(user_identity_email: [ :address ])
          address = address_params[:address]

          unless cloudflare_turnstile_validation["success"] && address.present?
            @user_email = UserIdentityEmail.new(address: address)
            return render :new, status: :unprocessable_content
          end

          normalized_address = validate_and_normalize_email(address)
          unless normalized_address
            @user_email = UserIdentityEmail.new(address: address)
            @user_email.errors.add(:address, t("sign.app.authentication.email.create.invalid_format"))
            return render :new, status: :unprocessable_content
          end

          process_email_authentication(normalized_address)

          # Preserve rd parameter if provided
          redirect_params = { notice: t("sign.app.authentication.email.create.verification_code_sent") }
          redirect_params[:rd] = params[:rd] if params[:rd].present?
          session[:user_email_authentication_rd] = params[:rd] if params[:rd].present?

          redirect_to edit_sign_app_authentication_email_path(redirect_params)
        end

        def update
          # nanikore?
          start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          @user_email.pass_code = update_pass_code_params[:pass_code]

          unless @user_email.valid?
            return render :edit, status: :unprocessable_content
          end

          result = verify_otp_and_login(@user_email)
          ensure_min_elapsed(start_time)

          if result[:success]
            # Redirect to rd parameter if provided, otherwise to root
            rd_param = params[:rd].presence || session[:user_email_authentication_rd]
            session[:user_email_authentication_rd] = nil

            if rd_param.present?
              flash[:notice] = t("sign.app.authentication.email.update.success")
              jump_to_generated_url(rd_param)
            else
              redirect_to "/", notice: t("sign.app.authentication.email.update.success")
            end
          else
            @user_email.errors.add(:pass_code, result[:error])
            render :edit, status: :unprocessable_content
          end
        end

        private

        def ensure_not_logged_in
          if logged_in?
            render plain: t("sign.app.authentication.email.new.you_have_already_logged_in"),
                   status: :bad_request
            nil
          end
        end

        def load_user_email
          if session[:user_email_authentication_id].present?
            @user_email = UserIdentityEmail.find_by(id: session[:user_email_authentication_id])
            return if @user_email.present? && !@user_email.otp_expired?

            redirect_params = { notice: t("sign.app.authentication.email.edit.session_expired") }
            redirect_params[:rd] = session[:user_email_authentication_rd] if session[:user_email_authentication_rd].present?
            redirect_to new_sign_app_authentication_email_path(redirect_params)
          elsif session[:user_email_authentication_address].present?
            @user_email = UserIdentityEmail.new(address: session[:user_email_authentication_address])
          else
            redirect_params = { notice: t("sign.app.authentication.email.edit.session_expired") }
            redirect_params[:rd] = session[:user_email_authentication_rd] if session[:user_email_authentication_rd].present?
            redirect_to new_sign_app_authentication_email_path(redirect_params)
          end
        end

        def process_email_authentication(normalized_address)
          existing_email = find_email_with_timing_protection(normalized_address)

          if existing_email
            otp_code = generate_otp_for(existing_email)
            session[:user_email_authentication_id] = existing_email.id
            session[:user_email_authentication_address] = nil

            Email::App::RegistrationMailer.with(
              hotp_token: otp_code,
              email_address: existing_email.address
            ).create.deliver_now
          else
            # Dummy work to simulate OTP generation for timing attack protection
            ROTP::Base32.random_base32
            ROTP::HOTP.new("dummy").at(0)

            session[:user_email_authentication_id] = nil
            session[:user_email_authentication_address] = normalized_address
          end
        end

        def generate_otp_for(user_email)
          otp_private_key = ROTP::Base32.random_base32
          otp_count_number = [ Time.now.to_i, SecureRandom.random_number(1 << 64) ].map(&:to_s).join.to_i
          hotp = ROTP::HOTP.new(otp_private_key)
          otp_code = hotp.at(otp_count_number)
          expires_at = 12.minutes.from_now.to_i

          user_email.store_otp(otp_private_key, otp_count_number, expires_at)
          otp_code
        end

        def verify_otp_and_login(user_email)
          if session[:user_email_authentication_id].present?
            verify_existing_email_otp(user_email)
          else
            verify_dummy_otp(user_email)
          end
        end

        def verify_existing_email_otp(user_email)
          otp_data = user_email.get_otp
          return { success: false, error: t("sign.app.authentication.email.edit.session_expired") } unless otp_data

          hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
          expected_code = hotp.at(otp_data[:otp_counter]).to_s

          if ActiveSupport::SecurityUtils.secure_compare(expected_code, user_email.pass_code)
            user_email.clear_otp
            session[:user_email_authentication_id] = nil
            session[:user] = { id: user_email.user_id }
            { success: true }
          else
            user_email.increment_attempts!
            handle_failed_otp_attempt(user_email)
          end
        end

        def verify_dummy_otp(user_email)
          # Perform timing attack protection
          ActiveSupport::SecurityUtils.secure_compare("000000", user_email.pass_code)
          { success: false, error: t("sign.app.authentication.email.update.invalid_code") }
        end

        def handle_failed_otp_attempt(user_email)
          if user_email.locked?
            { success: false, error: t("sign.app.authentication.email.locked") }
          else
            remaining = [ Email::MAX_OTP_ATTEMPTS - user_email.otp_attempts_count, 0 ].max
            { success: false, error: t("sign.app.authentication.email.update.invalid_code", attempts_left: remaining) }
          end
        end

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
