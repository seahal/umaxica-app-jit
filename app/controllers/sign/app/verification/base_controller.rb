# frozen_string_literal: true

require "json"

module Sign
  module App
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
        EMAIL_OTP_SESSION_KEY = :reauth_email_otp

        # scope => allowed return_to prefix pattern
        ALLOWED_SCOPES = {
          "configuration_email" => %r{\A/configuration/emails},
          "configuration_telephone" => %r{\A/configuration/telephones},
          "configuration_passkey" => %r{\A/configuration/passkeys},
          "configuration_mfa" => %r{\A/configuration/mfa},
          "configuration_secret" => %r{\A/configuration/secrets},
          "manage_totp" => %r{\A/configuration/totps},
          "withdrawal" => %r{\A/configuration/withdrawal},
          "social_unlink" => %r{\A/social/},
        }.freeze

        before_action :authenticate_user!
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

        # Called only at the entry point (/verification#show).
        # Decodes Base64-encoded return_to, validates scope + return_to, stores in session.
        def start_reauth_session!(scope:, return_to_param:)
          decoded = Base64.urlsafe_decode64(return_to_param.to_s)
          safe_path = safe_internal_path(decoded)
          raise ActionController::BadRequest, "invalid return_to" if safe_path.blank?

          scope_str = scope.to_s
          raise ActionController::BadRequest, "invalid scope" unless ALLOWED_SCOPES.key?(scope_str)

          pattern = ALLOWED_SCOPES[scope_str]
          raise ActionController::BadRequest, "scope mismatch" unless safe_path.match?(pattern)

          session[REAUTH_SESSION_KEY] = {
            "user_id" => current_user.id,
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

        # Validates the reauth session stored in Rails session.
        # Redirects and returns false if invalid; returns true if valid.
        def require_reauth_session!
          rs = current_reauth_session
          if valid_reauth_session?(rs)
            return true
          end

          clear_reauth_state!
          if restore_reauth_session_from_params! && valid_reauth_session?(current_reauth_session)
            return true
          end

          safe_redirect_to(
            sign_app_verification_path(verification_recovery_redirect_params),
            fallback: sign_app_verification_path(ri: params[:ri]),
            alert: I18n.t("auth.step_up.session_expired"),
          )
          false
        end

        # Consumes the reauth session after successful verification.
        # Updates the step-up token, deletes session, and redirects to return_to.
        def consume_reauth_session!
          rs = current_reauth_session
          return_to = rs["return_to"]
          scope = rs["scope"]

          now = Time.current
          verification, raw_token = UserVerification.issue_for_token!(token: @actor_token)
          @actor_token.update!(last_step_up_at: now, last_step_up_scope: scope)
          set_verification_cookie!(raw_token, expires_at: verification.expires_at)
          create_audit_event!(UserActivityEvent::STEP_UP_VERIFIED, subject: current_user)

          session.delete(REAUTH_SESSION_KEY)
          session.delete(EMAIL_OTP_SESSION_KEY)

          flash[:notice] = I18n.t("sign.app.verification.success.complete")
          safe_redirect_to(return_to, fallback: sign_app_verification_path(ri: params[:ri]))
        end

        # Checks that the given verification method is available for the current user.
        # Redirects and returns false if unavailable.
        def require_method_available!(method_sym)
          return true if available_step_up_methods.include?(method_sym)

          safe_redirect_to(
            sign_app_verification_path(ri: params[:ri]),
            fallback: "/verification",
            alert: I18n.t("auth.step_up.method_unavailable"),
          )
          false
        end

        def verification_params
          params.fetch(:verification, {}).permit(:code, :challenge_id, :credential_json, :scope, :return_to, :rd)
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

        def email_otp_session_active?
          data = session[EMAIL_OTP_SESSION_KEY]
          return false unless data

          Time.current.to_i <= data["expires_at"].to_i
        end

        def ensure_email_nonce!
          rs = current_reauth_session
          rs["email_nonce"] ||= SecureRandom.urlsafe_base64(16)
          session[REAUTH_SESSION_KEY] = rs
          rs["email_nonce"]
        end

        def current_reauth_scope
          current_reauth_session&.fetch("scope", nil)
        end

        def current_reauth_return_to_param
          return_to = current_reauth_session&.fetch("return_to", nil)
          return if return_to.blank?

          Base64.urlsafe_encode64(return_to)
        end

        def verification_recovery_redirect_params
          attrs = { ri: params[:ri] }

          scope = incoming_scope
          attrs[:scope] = scope if scope.present?

          return_to = incoming_return_to
          attrs[:return_to] = return_to if return_to.present?

          attrs
        end

        def valid_reauth_session?(rs)
          rs.present? &&
            rs["expires_at"].to_i > Time.current.to_i &&
            rs["user_id"] == current_user.id &&
            rs["scope"].present? &&
            rs["return_to"].present?
        end

        def restore_reauth_session_from_params!
          scope = incoming_scope
          return_to = incoming_return_to
          return false if scope.blank? || return_to.blank?

          start_reauth_session!(scope: scope, return_to_param: return_to)
          true
        rescue ActionController::BadRequest
          false
        end

        def incoming_scope
          verification_params[:scope].to_s.presence || params[:scope].to_s
        end

        def incoming_return_to
          verification_params[:return_to].to_s.presence ||
            verification_params[:rd].to_s.presence ||
            params[:return_to].to_s.presence ||
            params[:rd].to_s
        end

        def clear_reauth_state!
          session.delete(REAUTH_SESSION_KEY)
          session.delete(EMAIL_OTP_SESSION_KEY)
        end

        def set_verification_cookie!(raw_token, expires_at:)
          cookies[UserVerification.cookie_name] = {
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
            UserActivityEvent.find_or_create_by!(id: event_id)
            UserActivityLevel.find_or_create_by!(id: UserActivityLevel::NEYO)
          end

          UserActivity.create!(
            actor_type: "User",
            actor_id: current_user.id,
            event_id: event_id,
            subject_id: subject.id.to_s,
            subject_type: subject.class.name,
            occurred_at: Time.current,
          )
        end

        # ------------------------------------------------------------------
        # Passkey verification
        # ------------------------------------------------------------------

        def prepare_passkey_challenge!
          allow_credentials = current_user.user_passkeys.active.map { |pk| { id: pk.webauthn_id } }
          if allow_credentials.empty?
            @verification_errors = [I18n.t("sign.app.verification.errors.no_passkey", default: "パスキーが登録されていません")]
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
            passkey = UserPasskey.find_by(webauthn_id: credential.id)
            unless passkey && passkey.user_id == current_user.id
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
            current_user.user_one_time_passwords
              .where(user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE)
              .order(created_at: :desc)

          result = totps.any? { |totp| ROTP::TOTP.new(totp.private_key).verify(code) }
          @verification_errors = ["確認コードが正しくありません"] unless result
          result
        end

        # ------------------------------------------------------------------
        # Email OTP
        # ------------------------------------------------------------------

        def send_email_otp!
          user_email =
            current_user.user_emails.where(
              user_email_status_id: UserEmailStatus::VERIFIED,
            ).order(created_at: :desc).first
          unless user_email
            @verification_errors = ["メールアドレスが未確認です"]
            return false
          end

          secret, counter, pass_code = generate_hotp_code
          rs = current_reauth_session
          session[EMAIL_OTP_SESSION_KEY] = {
            "secret" => secret,
            "counter" => counter,
            "expires_at" => rs["expires_at"],
          }

          Email::App::RegistrationMailer.with(
            hotp_token: pass_code,
            email_address: user_email.address,
            public_id: current_user.public_id,
            verification_token: nil,
          ).create.deliver_later

          true
        end

        def verify_email_otp!
          code = verification_params[:code].to_s
          unless code.match?(/\A\d{6}\z/)
            @verification_errors = ["確認コードが不正です"]
            return false
          end

          data = session[EMAIL_OTP_SESSION_KEY]
          unless data
            @verification_errors = ["確認コードの再送信が必要です"]
            return false
          end

          if Time.current.to_i > data["expires_at"].to_i
            @verification_errors = ["確認コードの有効期限が切れました"]
            return false
          end

          ok = verify_hotp_code(secret: data["secret"], counter: data["counter"], pass_code: code)
          unless ok
            @verification_errors = ["確認コードが正しくありません"]
            return false
          end

          true
        end
      end
    end
  end
end
