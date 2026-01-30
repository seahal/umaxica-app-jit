# frozen_string_literal: true

module Sign
  module App
    module Up
      class EmailsController < ApplicationController
        include Sign::EmailRegistrable

        guest_only! message: I18n.t("sign.app.registration.email.already_logged_in")

        def show
          @user_email = UserEmail.find_by(public_id: params["id"])

          # TODO: 2FA setup hook
          # When implementing 2FA:
          #   - Display 2FA options (TOTP, SMS, etc.)
          #   - Call `setup_two_factor_auth(@user)` concern method
          #   - On success, complete registration flow
          prepare_two_factor_auth_options
        end

        def new
          @user_email = UserEmail.new
        end

        def edit
          @user_email = UserEmail.find_by(public_id: params["id"])
          return if valid_email_session?

          reset_email_flow!
          redirect_params = build_notice_params(t("sign.app.registration.email.edit.session_expired"))
          flash[:notice] = redirect_params.delete(:notice)
          redirect_to new_sign_app_up_email_path(redirect_params)
        end

        def create
          email_params = params.expect(user_email: [:address, :confirm_policy])

          unless initiate_email_verification!(email_params[:address], confirm_policy: email_params[:confirm_policy])
            render :new, status: :unprocessable_content
            return
          end

          progress_email_flow!(:create)
          redirect_params = build_notice_params(t("sign.app.registration.email.create.verification_code_sent"))
          flash[:notice] = redirect_params.delete(:notice)
          sanitize_redirect_params!(redirect_params)
          redirect_to edit_sign_app_up_email_path(@user_email, redirect_params)
        end

        def update
          @user_email = UserEmail.find_by(public_id: params["id"])

          # Validate email session before processing
          unless valid_email_session?
            reset_email_flow!
            redirect_params = build_notice_params(t("sign.app.registration.email.edit.session_expired"))
            flash[:notice] = redirect_params.delete(:notice)
            redirect_to new_sign_app_up_email_path(redirect_params)
            return
          end

          # Validate submitted code presence
          submitted_code = params.dig("user_email", "pass_code")
          if submitted_code.blank?
            @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.code_required"))
            render :edit, status: :unprocessable_content
            return
          end

          # Complete email verification
          result =
            complete_email_verification!(params["id"], submitted_code) do |user_email|
              create_user_and_login(user_email)
            end

          if result == :locked
            reset_email_flow!
            flash[:alert] = t("sign.app.registration.email.update.attempts_exceeded")
            redirect_to new_sign_app_up_email_path
            return
          elsif !result
            render :edit, status: :unprocessable_content
            return
          end

          progress_email_flow!(:update)
          redirect_to sign_app_configuration_path, notice: t("sign.app.registration.email.update.success")
        end

        def destroy
          # Reset flow and start over
          reset_flow!

          # TODO: 2FA cleanup hook
          # When implementing 2FA:
          #   - Clear any pending 2FA setup state
          #   - Call `cleanup_two_factor_auth_state` concern method
          cleanup_two_factor_auth_state

          redirect_params = build_notice_params(
            t("sign.app.registration.email.destroy.cancelled"),
          )
          flash[:notice] = redirect_params.delete(:notice)
          redirect_to new_sign_app_up_email_path(redirect_params)
        end

        private

        # ==========================================================================
        # 2FA Hooks (Future Implementation)
        # ==========================================================================

        # TODO: Implement 2FA setup options for show action
        def prepare_two_factor_auth_options
          # Future implementation:
          # @two_factor_methods = TwoFactorAuth.available_methods
          # @qr_code = TwoFactorAuth.generate_totp_qr(@user)
        end

        # TODO: Cleanup 2FA state on destroy/cancel
        def cleanup_two_factor_auth_state
          # Future implementation:
          # TwoFactorAuth.clear_pending_setup(session)
        end

        # ==========================================================================
        # Helpers
        # ==========================================================================

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
          elsif safe_external_url?(decoded_url)
            Base64.urlsafe_encode64(decoded_url)
          end
        rescue ArgumentError, URI::InvalidURIError
          nil
        end

        def valid_email_session?
          @user_email.present? &&
            !@user_email.otp_expired? &&
            @user_email.user_email_status_id == "UNVERIFIED_WITH_SIGN_UP"
        end

        def create_user_and_login(user_email)
          ActiveRecord::Base.transaction do
            @user = User.create!(status_id: "VERIFIED_WITH_SIGN_UP")
            user_email.user = @user
            audit = UserAudit.new(actor: @user, event_id: "SIGNED_UP_WITH_EMAIL", user: @user)
            audit.save!
            user_email.save!
          end
          log_in(@user, record_login_audit: false)
        end
      end
    end
  end
end
