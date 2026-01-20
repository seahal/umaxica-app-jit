# frozen_string_literal: true

module Sign
  module App
    module In
      class EmailsController < ApplicationController
        include ::CloudflareTurnstile
        include EmailValidation
        include ::Redirect
        include Common::Otp

        guest_only! status: :bad_request,
                    message: I18n.t("sign.app.authentication.email.new.you_have_already_logged_in")

        before_action :load_user_email, only: %i(edit update)

        def new
          @user_email = UserEmail.new
        end

        def edit
        end

        def create
          address_params = params.expect(user_email: [:address])
          address = address_params[:address]

          unless cloudflare_turnstile_validation["success"] && address.present?
            @user_email = UserEmail.new(address: address)
            return render :new, status: :unprocessable_content
          end

          normalized_address = validate_and_normalize_email(address)
          unless normalized_address
            @user_email = UserEmail.new(address: address)
            @user_email.errors.add(:address, t("sign.app.authentication.email.create.invalid_format"))
            return render :new, status: :unprocessable_content
          end

          process_email_authentication(normalized_address)

          # Preserve rd parameter if provided
          preserve_redirect_parameter
          redirect_params = build_notice_params(t("sign.app.authentication.email.create.verification_code_sent"))

          redirect_to edit_sign_app_in_email_path(redirect_params)
        end

        def update
          # Record start time for timing attack mitigation
          start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          @user_email.pass_code = update_pass_code_params[:pass_code]

          unless @user_email.valid?
            respond_to do |format|
              format.html { render :edit, status: :unprocessable_content }
              format.json {
                render json: { error: @user_email.errors.full_messages.join(", ") }, status: :unprocessable_content
              }
            end
            return
          end

          result = verify_otp_and_login(@user_email)
          ensure_min_elapsed(start_time)

          if result[:success]
            respond_to do |format|
              format.html do
                if result[:redirect_path]
                  redirect_to result[:redirect_path], notice: t("sign.app.authentication.totp.required")
                else
                  # Redirect to rd parameter if provided, otherwise to root
                  redirect_with_notice("/", t("sign.app.authentication.email.update.success"))
                end
              end
              format.json do
                # Return tokens for JSON API clients
                render json: result[:tokens], status: :ok
              end
            end
          else
            @user_email.errors.add(:pass_code, result[:error])
            respond_to do |format|
              format.html { render :edit, status: :unprocessable_content }
              format.json { render json: { error: result[:error] }, status: :unprocessable_content }
            end
          end
        end

        private

        def load_user_email
          if session[:user_email_authentication_id].present?
            @user_email = load_session_record(
              :user_email_authentication_id,
              UserEmail,
              check_otp_expiry: false,
              custom: ->(email) { email.present? && !email.otp_expired? },
            )

            unless @user_email
              redirect_params = build_notice_params(t("sign.app.authentication.email.edit.session_expired"))
              redirect_to new_sign_app_in_email_path(redirect_params)
            end
          elsif session[:user_email_authentication_address].present?
            @user_email = UserEmail.new(address: session[:user_email_authentication_address])
          else
            redirect_params = build_notice_params(t("sign.app.authentication.email.edit.session_expired"))
            redirect_to new_sign_app_in_email_path(redirect_params)
          end
        end

        def process_email_authentication(normalized_address)
          existing_email = find_email_with_timing_protection(normalized_address)

          if existing_email
            session[:user_email_authentication_id] = existing_email.id
            session[:user_email_authentication_address] = nil

            return if otp_request_rate_limited?(existing_email)

            otp_code = generate_otp_for(existing_email)

            Email::App::RegistrationMailer.with(
              hotp_token: otp_code,
              email_address: existing_email.address,
            ).create.deliver_later
          else
            # Dummy work to simulate OTP generation for timing attack protection
            perform_dummy_otp_generation

            session[:user_email_authentication_id] = nil
            session[:user_email_authentication_address] = normalized_address
          end
        end

        def verify_otp_and_login(user_email)
          if session[:user_email_authentication_id].present?
            verify_existing_email_otp(user_email)
          else
            verify_dummy_otp(user_email)
          end
        end

        def verify_existing_email_otp(user_email)
          result = verify_otp_code(user_email, user_email.pass_code)

          if result[:success]
            user = user_from_user_email(user_email)
            clear_otp(user_email)
            session[:user_email_authentication_id] = nil
            result = log_in(user)
            if result[:status] == :totp_required
              { success: true, redirect_path: new_sign_app_in_totp_path }
            else
              { success: true, tokens: result }
            end
          else
            user = user_from_user_email(user_email)
            increment_otp_attempts!(user_email)
            handle_failed_otp_attempt(user_email, user)
          end
        end

        def verify_dummy_otp(user_email)
          # Perform timing attack protection
          super(user_email.pass_code)
          { success: false, error: t("sign.app.authentication.email.update.invalid_code") }
        end

        def handle_failed_otp_attempt(user_email, user = nil)
          user ||= user_from_user_email(user_email)
          audit_user_login_failed(user) if user

          if user_email.locked?
            { success: false, error: t("sign.app.authentication.email.locked") }
          else
            remaining = [Email::MAX_OTP_ATTEMPTS - user_email.otp_attempts_count, 0].max
            { success: false,
              error: t("sign.app.authentication.email.update.invalid_code", attempts_left: remaining), }
          end
        end

        def update_pass_code_params
          params.expect(user_email: [:pass_code])
        rescue ActionController::ParameterMissing
          {}
        end

        def user_from_user_email(user_email)
          user_email.user || User.find_by(id: user_email.user_id)
        end

        def otp_request_rate_limited?(user_email)
          return false unless user_email.otp_cooldown_active?

          true
        end
      end
    end
  end
end
