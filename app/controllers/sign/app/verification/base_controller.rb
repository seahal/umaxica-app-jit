# frozen_string_literal: true

require "json"

module Sign
  module App
    module Verification
      class BaseController < ApplicationController
        include Common::Otp
        include ::Auth::StepUp
        include Sign::Webauthn

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

        private

        def require_ri!
          params.require(:ri)
        end

        def set_actor_token
          @actor_token = token_class.find_by!(public_id: current_session_public_id)
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
          if rs.present? &&
              rs["expires_at"].to_i > Time.current.to_i &&
              rs["user_id"] == current_user.id &&
              rs["scope"].present?
            return true
          end

          session.delete(REAUTH_SESSION_KEY)
          session.delete(EMAIL_OTP_SESSION_KEY)
          redirect_to sign_app_configuration_path(ri: params[:ri]),
                      alert: I18n.t("auth.step_up.session_expired", default: "再認証が必要です")
          false
        end

        # Consumes the reauth session after successful verification.
        # Updates the step-up token, deletes session, and redirects to return_to.
        def consume_reauth_session!
          rs = current_reauth_session
          return_to = rs["return_to"]
          scope = rs["scope"]

          now = Time.current
          @actor_token.update!(last_step_up_at: now, last_step_up_scope: scope)

          session.delete(REAUTH_SESSION_KEY)
          session.delete(EMAIL_OTP_SESSION_KEY)

          flash[:notice] = I18n.t("sign.app.verification.success.complete")
          safe_redirect_to(return_to, fallback: sign_app_configuration_path(ri: params[:ri]))
        end

        # Checks that the given verification method is available for the current user.
        # Redirects and returns false if unavailable.
        def require_method_available!(method_sym)
          return true if available_step_up_methods.include?(method_sym)

          redirect_to sign_app_verification_path(ri: params[:ri]),
                      alert: I18n.t("auth.step_up.method_unavailable", default: "この認証方法は利用できません")
          false
        end

        def verification_params
          params.fetch(:verification, {}).permit(:code, :challenge_id, :credential_json)
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
