# frozen_string_literal: true

module Sign
  module App
    module Up
      class EmailsController < ApplicationController
        include ::CloudflareTurnstile
        include ::Redirect
        include Sign::OtpAuthentication
        include Sign::RedirectParameterHandling
        include Sign::PreAuthenticationGuards

        before_action :ensure_not_logged_in_for_registration

        def new
          # make user email
          @user_email = UserEmail.new
        end

        def edit
          @user_email = UserEmail.find_by(id: params["id"])
          if @user_email.blank? ||
              @user_email.otp_expired? ||
              @user_email.user_email_status_id != "UNVERIFIED_WITH_SIGN_UP"
            redirect_params = build_notice_params(t("sign.app.registration.email.edit.session_expired"))
            redirect_to new_sign_app_up_email_path(redirect_params)
          end
        end

        def create
          # Validate Cloudflare Turnstile first
          turnstile_result = cloudflare_turnstile_validation

          # Build new email record
          @user_email = UserEmail.new(params.expect(user_email: [:address, :confirm_policy]))
          @user_email.user_email_status_id = "UNVERIFIED_WITH_SIGN_UP"

          # Check turnstile validation
          unless turnstile_result["success"]
            @user_email.errors.add(:base, t("sign.app.registration.email.create.turnstile_validation_failed"))
            render :new, status: :unprocessable_content and return
          end

          # Delete existing unverified email with same address to allow re-registration
          if @user_email.address.present?
            UserEmail.where(
              address: @user_email.address,
              user_email_status_id: "UNVERIFIED_WITH_SIGN_UP",
            ).destroy_all
          end

          # Generate OTP
          num = generate_otp_attributes(@user_email)

          # Validate the new email
          unless @user_email.valid?
            render :new, status: :unprocessable_content and return
          end

          # Save email and store OTP in database
          @user_email.save!

          # Send email
          Email::App::RegistrationMailer.with(
            { hotp_token: num,
              email_address: @user_email.address, },
          ).create.deliver_later

          # Preserve rd parameter if provided
          redirect_params = build_notice_params(t("sign.app.registration.email.create.verification_code_sent"))

          redirect_to edit_sign_app_up_email_path(@user_email.id, redirect_params)
        end

        def update
          # Retrieve email record with OTP
          @user_email = UserEmail.find_by(id: params["id"])
          if @user_email.blank? ||
              @user_email.otp_expired? ||
              @user_email.user_email_status_id != "UNVERIFIED_WITH_SIGN_UP"
            redirect_params = build_alert_params(t("sign.app.registration.email.update.session_expired"))
            redirect_to new_sign_app_up_email_path(redirect_params) and return
          end

          # Verify OTP using secure_compare
          submitted_code = params["user_email"]["pass_code"]
          result = verify_otp_code(@user_email, submitted_code)

          unless result[:success]
            increment_otp_attempts!(@user_email)
            if @user_email.locked?
              @user_email.destroy!
              redirect_params = build_alert_params(t("sign.app.registration.email.update.attempts_exceeded"))
              redirect_to new_sign_app_up_email_path(redirect_params) and return
            end
            @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.invalid_code"))
            render :edit, status: :unprocessable_content and return
          end

          # Clear OTP and complete registration
          clear_otp(@user_email)
          @user_email.user_email_status_id = "VERIFIED_WITH_SIGN_UP"

          # Create user and link email atomically within a transaction
          begin
            ActiveRecord::Base.transaction do
              # Use create! to raise exception on validation failure
              @user = User.create!(status_id: "VERIFIED_WITH_SIGN_UP")
              # Use association to set the user
              @user_email.user = @user
              audit = UserAudit.new(actor: @user, event_id: "SIGNED_UP_WITH_EMAIL")
              audit.user = @user
              audit.save!
              @user_email.save!
            end
          rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
            @user_email.errors.add(:base, t("sign.app.registration.email.update.failed"))
            render :edit, status: :unprocessable_content and return
          end

          # Set user session after successful transaction
          log_in(@user, record_login_audit: false)

          # Redirect to rd parameter if provided, otherwise to root
          redirect_with_notice("/", t("sign.app.registration.email.update.success"))
        end

        private
      end
    end
  end
end
