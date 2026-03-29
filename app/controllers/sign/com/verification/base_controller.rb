# typed: false
# frozen_string_literal: true

# FIXME: BaseController is bad practive, and you should remove this.
module Sign
  module Com
    module Verification
      class BaseController < Sign::Com::ApplicationController
        auth_required!

        include Sign::AppVerificationBase

        private

        def reauth_actor_id
          current_customer.id
        end

        def valid_reauth_session?(rs)
          rs.present? &&
            rs["expires_at"].to_i > Time.current.to_i &&
            rs["user_id"] == current_customer.id &&
            rs["scope"].present? &&
            rs["return_to"].present?
        end

        def handle_invalid_reauth_session!
          clear_reauth_state!
          if restore_reauth_session_from_params! && valid_reauth_session?(current_reauth_session)
            return true
          end

          safe_redirect_to(
            sign_com_verification_path(verification_recovery_redirect_params),
            fallback: sign_com_verification_path(ri: params[:ri]),
            alert: I18n.t("auth.step_up.session_expired"),
          )
          false
        end

        def verification_unavailable_redirect_path
          sign_com_verification_path(ri: params[:ri])
        end

        def clear_reauth_state!
          session.delete(self.class::REAUTH_SESSION_KEY)
          session.delete(self.class::EMAIL_OTP_SESSION_KEY)
        end

        def verification_model
          UserVerification
        end

        def verification_success_event_id
          UserActivityEvent::STEP_UP_VERIFIED
        end

        def verification_success_notice_key
          "sign.app.verification.success.complete"
        end

        def verification_success_fallback_path
          sign_com_verification_path(ri: params[:ri])
        end

        def verification_audit_event_class = UserActivityEvent

        def verification_audit_level_class = UserActivityLevel

        def verification_default_activity_level_id = UserActivityLevel::NOTHING

        def verification_activity_model = UserActivity

        def current_verification_actor = current_customer

        def verification_actor_type = "User"

        def verification_passkeys_scope
          current_customer.user_passkeys
        end

        def verification_passkey_model
          UserPasskey
        end

        def passkey_actor_matches?(passkey)
          passkey.user_id == current_customer.id
        end

        def verification_no_passkey_i18n_key
          "sign.app.verification.errors.no_passkey"
        end

        def active_totp_credentials
          UserOneTimePassword.none
        end

        def step_up_supported_methods
          %i(email_otp passkey)
        end

        def send_email_otp!
          user_email =
            current_customer.user_emails.where(
              user_email_status_id: UserEmailStatus::VERIFIED,
            ).order(created_at: :desc).first
          unless user_email
            @verification_errors = ["メールアドレスが未確認です"]
            return false
          end

          secret, counter, pass_code = generate_hotp_code
          rs = current_reauth_session
          session[self.class::EMAIL_OTP_SESSION_KEY] = {
            "secret" => secret,
            "counter" => counter,
            "expires_at" => rs["expires_at"],
          }

          Email::App::RegistrationMailer.with(
            hotp_token: pass_code,
            email_address: user_email.address,
            public_id: current_customer.public_id,
            verification_token: nil,
          ).create.deliver_later

          true
        end
      end
    end
  end
end
