# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Up
      class EmailsController < ApplicationController
        include Sign::EmailRegistrable
        include ::CloudflareTurnstile

        guest_only! message: I18n.t("sign.app.registration.email.already_logged_in")

        def new
          @user_email = UserEmail.new
        end

        def edit
          @user_email = UserEmail.find_by(public_id: params["id"])

          # Security: Verify email exists and belongs to current session
          if @user_email.blank?
            reset_email_flow!
            redirect_to(
              new_sign_app_up_email_path,
              notice: t("sign.app.registration.email.edit.not_found"),
            )
            return
          end

          # Security: Validate the email belongs to the current registration flow
          return if valid_email_session?

          reset_email_flow!
          redirect_params = build_notice_params(t("sign.app.registration.email.edit.session_expired"))
          flash[:notice] = redirect_params.delete(:notice)
          redirect_to(new_sign_app_up_email_path(redirect_params))
          nil
        end

        def create
          email_params = params.expect(user_email: %i(raw_address address confirm_policy))
          email_address = email_params[:raw_address] || email_params[:address]

          unless cloudflare_turnstile_validation["success"]
            @user_email = UserEmail.new(address: email_address)
            @user_email.errors.add(
              :base, t(
                "sign.app.registration.email.create.turnstile_failed",
                default: "ボット検証に失敗しました。もう一度お試しください。",
              ),
            )
            render :new, status: :unprocessable_content
            return
          end

          result = initiate_email_verification!(
            email_address,
            confirm_policy: email_params[:confirm_policy],
            allow_existing: true,
          )

          if result == :cooldown
            render plain: t("sign.app.registration.email.create.otp_resend_too_soon"),
                   status: :too_many_requests
            return
          end

          unless result
            log_signup_email_errors
            render :new, status: :unprocessable_content
            return
          end

          progress_email_flow!(:create)
          redirect_params = build_notice_params(t("sign.app.registration.email.create.verification_code_sent"))
          flash[:notice] = redirect_params.delete(:notice)
          sanitize_redirect_params!(redirect_params)
          redirect_to(edit_sign_app_up_email_path(@user_email, redirect_params))
        end

        def update
          @user_email = UserEmail.find_by(public_id: params["id"])

          # Validate email session before processing
          unless valid_email_session?
            reset_email_flow!
            redirect_params = build_notice_params(t("sign.app.registration.email.edit.session_expired"))
            flash[:notice] = redirect_params.delete(:notice)
            redirect_to(new_sign_app_up_email_path(redirect_params))
            return
          end

          # Validate submitted code presence
          submitted_code = params.dig("user_email", "pass_code")
          if submitted_code.blank?
            @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.code_required"))
            render :edit, status: :unprocessable_content
            return
          end

          if existing_signup_email_flow?
            result = handle_existing_email_verification(submitted_code)
            return if result == :redirected
          else
            result =
              complete_email_verification!(params["id"], submitted_code) do |user_email|
                create_user_and_login(user_email)
              end
          end

          if result == :locked
            reset_email_flow!
            flash[:alert] = t("sign.app.registration.email.update.attempts_exceeded")
            redirect_to(new_sign_app_up_email_path)
            return
          elsif !result
            render :edit, status: :unprocessable_content
            return
          end

          progress_email_flow!(:update)
          issue_checkpoint!
          redirect_to(
            sign_app_in_checkpoint_path(rd: params[:rd], ri: params[:ri]),
            notice: t("sign.app.registration.email.update.success"),
          )
        end

        private

        def sanitize_redirect_params!(redirect_params)
          return if redirect_params[:rd].blank?

          redirect_params[:rd] = sanitize_encoded_redirect(redirect_params[:rd])
          redirect_params.delete(:rd) if redirect_params[:rd].blank?
        end

        def sanitize_encoded_redirect(encoded_url)
          return if encoded_url.blank?

          decoded_url = Base64.urlsafe_decode64(encoded_url)
          safe_path = safe_internal_path(decoded_url)

          if safe_path
            Base64.urlsafe_encode64(safe_path)
          end
        rescue ArgumentError, URI::InvalidURIError
          nil
        end

        def valid_email_session?
          return false if @user_email.blank?

          if existing_signup_email_flow?
            return false unless Integer(session_existing_email_id.to_s, 10) == @user_email.id

            existing_signup_skip_otp? || !@user_email.otp_expired?
          else
            return false if @user_email.otp_expired?

            @user_email.user_email_status_id == UserEmailStatus::UNVERIFIED_WITH_SIGN_UP
          end
        end

        def existing_signup_email_flow?
          session_existing_email_id.present?
        end

        def session_existing_email_id
          session[Sign::EmailRegistrable::EXISTING_EMAIL_SESSION_KEY]
        end

        def existing_signup_skip_otp?
          session[Sign::EmailRegistrable::EXISTING_EMAIL_SKIP_OTP_SESSION_KEY] == true
        end

        def handle_existing_email_verification(submitted_code)
          if existing_signup_skip_otp?
            reset_email_flow!
            redirect_to(
              new_sign_app_in_path,
              notice: t("sign.app.registration.email.update.sign_in_required"),
            )
            return :redirected
          end

          result = verify_otp_code(@user_email, submitted_code)
          unless result[:success]
            increment_otp_attempts!(@user_email)
            if @user_email.locked?
              reset_email_flow!
              return :locked
            end

            @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.invalid_code"))
            return false
          end

          clear_otp(@user_email)
          reset_email_flow!
          session.delete(Sign::EmailRegistrable::EXISTING_EMAIL_SESSION_KEY)
          redirect_to(
            new_sign_app_in_path,
            notice: t("sign.app.registration.email.update.sign_in_required"),
          )
          :redirected
        end

        def create_user_and_login(user_email)
          # Update existing pending user to verified status
          # Note: This is called within complete_email_verification!'s transaction
          @user = user_email.user
          @user.update!(status_id: UserStatus::VERIFIED_WITH_SIGN_UP)

          create_signup_audit!

          user_email.save!
          log_in(@user, record_login_audit: false)
        end

        def create_signup_audit!
          event_id = UserActivityEvent::SIGNED_UP_WITH_EMAIL

          ActivityRecord.connected_to(role: :writing) do
            UserActivityEvent.find_or_create_by!(id: event_id)
            UserActivityLevel.find_or_create_by!(id: UserActivityLevel::NOTHING)
          end

          audit = UserActivity.new(
            actor_type: "User",
            actor_id: @user.id,
            event_id: event_id,
            subject_id: @user.id.to_s,
            subject_type: "User",
          )
          audit.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.event.error(
            "sign.signup.email.audit_save_failed",
            user_id: @user&.id,
            event_id: event_id,
            errors: e.record.errors.full_messages,
            exception: e,
          )
          raise
        end

        private

        def log_signup_email_errors
          return unless @user_email&.errors&.any?

          Rails.event.warn(
            "sign.signup.email.validation_failed",
            errors: @user_email.errors.full_messages,
          )
        end
      end
    end
  end
end
