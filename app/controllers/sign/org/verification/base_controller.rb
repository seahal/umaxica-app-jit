# frozen_string_literal: true

require "json"

module Sign
  module Org
    module Verification
      class BaseController < ApplicationController
        include ::Preference::Global
        include Common::Otp
        include ::Auth::StepUp
        include Sign::Webauthn
        include Sign::VerificationTiming

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

        def require_ri!
          params.require(:ri)
        end

        def set_actor_token
          @actor_token = token_class.find_by!(public_id: current_session_public_id)
        end

        def actor_token
          @actor_token
        end

        # ------------------------------------------------------------------
        # Session-based reauth state management
        # ------------------------------------------------------------------

        def start_reauth_session!(scope:, return_to_param:)
          decoded = Base64.urlsafe_decode64(return_to_param.to_s)
          safe_path = safe_internal_path(decoded)
          raise ActionController::BadRequest, "invalid return_to" if safe_path.blank?

          scope_str = scope.to_s
          raise ActionController::BadRequest, "invalid scope" unless ALLOWED_SCOPES.key?(scope_str)

          pattern = ALLOWED_SCOPES[scope_str]
          raise ActionController::BadRequest, "scope mismatch" unless safe_path.match?(pattern)

          session[REAUTH_SESSION_KEY] = {
            "user_id" => current_staff.id,
            "scope" => scope_str,
            "return_to" => safe_path,
            "expires_at" => REAUTH_TTL.from_now.to_i,
          }
        rescue ArgumentError
          raise ActionController::BadRequest, "invalid return_to encoding"
        end

        def current_reauth_session
          session[REAUTH_SESSION_KEY]
        end

        def require_reauth_session!
          rs = current_reauth_session
          if rs.present? &&
              rs["expires_at"].to_i > Time.current.to_i &&
              rs["user_id"] == current_staff.id &&
              rs["scope"].present?
            return true
          end

          session.delete(REAUTH_SESSION_KEY)
          safe_redirect_to(
            sign_org_configuration_path(ri: params[:ri]),
            fallback: "/configuration",
            alert: I18n.t("auth.step_up.session_expired"),
          )
          false
        end

        def consume_reauth_session!
          rs = current_reauth_session
          return_to = rs["return_to"]
          scope = rs["scope"]

          now = Time.current
          verification, raw_token = StaffVerification.issue_for_token!(token: @actor_token)
          @actor_token.update!(last_step_up_at: now, last_step_up_scope: scope)
          set_verification_cookie!(raw_token, expires_at: verification.expires_at)
          create_audit_event!(StaffActivityEvent::STEP_UP_VERIFIED, subject: current_staff)

          session.delete(REAUTH_SESSION_KEY)

          flash[:notice] = I18n.t("sign.org.verification.success.complete")
          safe_redirect_to(return_to, fallback: sign_org_verification_path(ri: params[:ri]))
        end

        def require_method_available!(method_sym)
          return true if available_step_up_methods.include?(method_sym)

          safe_redirect_to(
            sign_org_verification_path(ri: params[:ri]),
            fallback: "/verification",
            alert: I18n.t("auth.step_up.method_unavailable"),
          )
          false
        end

        def verification_params
          params.fetch(:verification, {}).permit(:code, :challenge_id, :credential_json)
        end

        def verification_scope
          current_reauth_session&.fetch("scope", nil)
        end

        def redirect_if_recent_verification_for_get!
          scope = verification_scope
          return false unless scope
          return false unless verification_recent_for_get?(scope: scope)

          consume_reauth_session!
          true
        end

        def redirect_if_recent_verification_for_post!
          scope = verification_scope
          return false unless scope
          return false unless verification_recent_for_post?(scope: scope)

          consume_reauth_session!
          true
        end

        # ------------------------------------------------------------------
        # Passkey verification
        # ------------------------------------------------------------------

        def prepare_passkey_challenge!
          allow_credentials = current_staff.staff_passkeys.active.map { |pk| { id: pk.webauthn_id } }
          if allow_credentials.empty?
            @verification_errors = [I18n.t("sign.org.verification.errors.no_passkey", default: "パスキーが登録されていません")]
            return false
          end

          @passkey_challenge_id, @passkey_request_options =
            create_authentication_challenge(allow_credentials: allow_credentials)
          true
        end

        def verify_passkey!
          challenge_id = verification_params[:challenge_id].to_s
          credential_json = verification_params[:credential_json].to_s
          if challenge_id.blank? || credential_json.blank?
            @verification_errors = ["パスキー認証データが不足しています"]
            return false
          end

          credential_hash = JSON.parse(credential_json)

          with_challenge(challenge_id, purpose: :authentication) do |challenge|
            credential = WebAuthn::Credential.from_get(credential_hash, relying_party: webauthn_relying_party)
            passkey = StaffPasskey.find_by(webauthn_id: credential.id)
            unless passkey && passkey.staff_id == current_staff.id
              @verification_errors = [I18n.t("errors.webauthn.credential_not_found")]
              next false
            end

            credential.verify(
              challenge,
              public_key: passkey.public_key,
              sign_count: passkey.sign_count,
            )
            passkey.update!(sign_count: credential.sign_count)
            true
          end
        rescue Sign::Webauthn::ChallengeNotFoundError,
               Sign::Webauthn::ChallengeExpiredError,
               Sign::Webauthn::ChallengePurposeMismatchError
          @verification_errors = [I18n.t("errors.webauthn.challenge_invalid")]
          false
        rescue WebAuthn::Error, JSON::ParserError
          @verification_errors = [I18n.t("errors.webauthn.verification_failed")]
          false
        end

        # ------------------------------------------------------------------
        # TOTP verification
        # ------------------------------------------------------------------

        def verify_totp!
          code = verification_params[:code].to_s
          unless code.match?(/\A\d{6}\z/)
            @verification_errors = ["確認コードが不正です"]
            return false
          end

          totps =
            current_staff.staff_one_time_passwords
              .where(staff_one_time_password_status_id: StaffOneTimePasswordStatus::ACTIVE)
              .order(created_at: :desc)

          result = totps.any? { |totp| ROTP::TOTP.new(totp.private_key).verify(code) }
          @verification_errors = ["確認コードが正しくありません"] unless result
          result
        end

        def set_verification_cookie!(raw_token, expires_at:)
          cookies[StaffVerification.cookie_name] = {
            value: raw_token,
            expires: expires_at,
            httponly: true,
            secure: Rails.env.production? || request.ssl?,
            same_site: :lax,
            path: "/",
          }
        end

        def create_audit_event!(event_id, subject:)
          ActivityRecord.connected_to(role: :writing) do
            StaffActivityEvent.find_or_create_by!(id: event_id)
            StaffActivityLevel.find_or_create_by!(id: StaffActivityLevel::NEYO)
          end

          StaffActivity.create!(
            actor_type: "Staff",
            actor_id: current_staff.id,
            event_id: event_id,
            subject_id: subject.id.to_s,
            subject_type: subject.class.name,
            occurred_at: Time.current,
          )
        end
      end
    end
  end
end
