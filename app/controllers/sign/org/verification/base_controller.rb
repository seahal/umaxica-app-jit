# frozen_string_literal: true

require "json"

module Sign
  module Org
    module Verification
      class BaseController < ApplicationController
        include ::Preference::Global
        include Common::Otp
        include ::Verification::Staff
        include Sign::Webauthn
        include Sign::VerificationTiming
        include Sign::VerificationCommonBase
        include Sign::VerificationAuditAndCookie
        include Sign::VerificationReauthSessionStore
        include Sign::VerificationReauthLifecycle
        include Sign::VerificationPasskeyChecks
        include Sign::VerificationTotpChecks

        auth_required!

        REAUTH_TTL = 15.minutes
        REAUTH_SESSION_KEY = :reauth

        # scope => allowed return_to prefix pattern
        ALLOWED_SCOPES = {
          "configuration_passkey" => %r{\A/configuration/passkeys},
          "configuration_mfa" => %r{\A/configuration/mfa},
          "configuration_secret" => %r{\A/configuration/secrets},
          "manage_totp" => %r{\A/configuration/totps},
          "withdrawal" => %r{\A/configuration/withdrawal},
        }.freeze

        before_action :authenticate_staff!
        before_action :set_actor_token
        before_action :require_ri!
        before_action :enforce_step_up_prereqs!

        private

        # ------------------------------------------------------------------
        # Session-based reauth state management
        # ------------------------------------------------------------------

        def verification_params
          params.fetch(:verification, {}).permit(:code, :challenge_id, :credential_json)
        end

        def active_totp_credentials
          current_staff.staff_one_time_passwords
            .where(staff_one_time_password_status_id: StaffOneTimePasswordStatus::ACTIVE)
            .order(created_at: :desc)
        end

        def verification_unavailable_redirect_path
          sign_org_verification_path(ri: params[:ri])
        end

        def reauth_actor_id
          current_staff.id
        end

        def valid_reauth_session?(rs)
          rs.present? &&
            rs["expires_at"].to_i > Time.current.to_i &&
            rs["user_id"] == current_staff.id &&
            rs["scope"].present?
        end

        def handle_invalid_reauth_session!
          clear_reauth_state!
          safe_redirect_to(
            sign_org_configuration_path(ri: params[:ri]),
            fallback: "/configuration",
            alert: I18n.t("auth.step_up.session_expired"),
          )
          false
        end

        def clear_reauth_state!
          session.delete(REAUTH_SESSION_KEY)
        end

        def verification_model
          StaffVerification
        end

        def verification_success_event_id
          StaffActivityEvent::STEP_UP_VERIFIED
        end

        def verification_success_notice_key
          "sign.org.verification.success.complete"
        end

        def verification_success_fallback_path
          sign_org_verification_path(ri: params[:ri])
        end

        def verification_audit_event_class = StaffActivityEvent

        def verification_audit_level_class = StaffActivityLevel

        def verification_default_activity_level_id = StaffActivityLevel::NEYO

        def verification_activity_model = StaffActivity

        def current_verification_actor = current_staff

        def verification_actor_type = "Staff"

        def verification_passkeys_scope
          current_staff.staff_passkeys
        end

        def verification_passkey_model
          StaffPasskey
        end

        def passkey_actor_matches?(passkey)
          passkey.staff_id == current_staff.id
        end

        def verification_no_passkey_i18n_key
          "sign.org.verification.errors.no_passkey"
        end
      end
    end
  end
end
