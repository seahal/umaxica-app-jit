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
        EMAIL_OTP_SESSION_KEY = :reauth_email_otp

        before_action :authenticate_user!
        before_action :set_actor_token

        private

        def set_actor_token
          @actor_token = token_class.find_by!(public_id: current_session_public_id)
        end

        def load_reauth_session!(id)
          @reauth_session = ReauthSession.for_actor(@actor_token).find(id)
        end

        def ensure_pending_and_not_expired!
          return true if @reauth_session.status == "PENDING" && @reauth_session.expires_at > Time.current

          head(:gone)
          false
        end

        def verification_params
          params.fetch(:verification, {}).permit(
            :scope,
            :return_to,
            :session_id,
            :code,
            :challenge_id,
            :credential_json,
          )
        end

        def build_reauth_session!(method:, scope:, return_to:)
          @reauth_session =
            ReauthSession.new(
              actor: @actor_token,
              scope: scope.to_s,
              return_to: normalize_encoded_return_to!(return_to.to_s),
              method: method,
              status: "PENDING",
              expires_at: 10.minutes.from_now,
            )
          @reauth_session.save!
          @reauth_session
        end

        def normalize_encoded_return_to!(encoded)
          decoded = Base64.urlsafe_decode64(encoded)
          safe = safe_internal_path(decoded)
          raise ArgumentError, "unsafe return_to" if safe.blank?

          Base64.urlsafe_encode64(safe)
        rescue ArgumentError
          raise
        end

        def prepare_method_side_effects!(reauth_session)
          case reauth_session.method
          when "email_otp"
            send_email_otp!(reauth_session)
          end
        end

        def send_email_otp!(reauth_session)
          user_email =
            current_user.user_emails.where(
              user_email_status_id: UserEmailStatus::VERIFIED,
            ).order(created_at: :desc).first
          unless user_email
            reauth_session.update!(status: "CANCELLED")
            reauth_session.errors.add(:base, "メールアドレスが未確認です")
            raise ActiveRecord::RecordInvalid, reauth_session
          end

          secret, counter, pass_code = generate_hotp_code
          session[EMAIL_OTP_SESSION_KEY] ||= {}
          session[EMAIL_OTP_SESSION_KEY][reauth_session.id] = {
            "secret" => secret,
            "counter" => counter,
            "expires_at" => reauth_session.expires_at.to_i,
          }

          Email::App::RegistrationMailer.with(
            hotp_token: pass_code,
            email_address: user_email.address,
            public_id: current_user.public_id,
            verification_token: nil,
          ).create.deliver_later
        end

        def verify_totp!
          code = verification_params[:code].to_s
          unless code.match?(/\A\d{6}\z/)
            @reauth_session.errors.add(:base, "確認コードが不正です")
            return false
          end

          totps =
            current_user.user_one_time_passwords
              .where(user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE)
              .order(created_at: :desc)

          totps.any? do |totp|
            ROTP::TOTP.new(totp.private_key).verify(code)
          end
        end

        def verify_email_otp!
          code = verification_params[:code].to_s
          unless code.match?(/\A\d{6}\z/)
            @reauth_session.errors.add(:base, "確認コードが不正です")
            return false
          end

          data = session.dig(EMAIL_OTP_SESSION_KEY, @reauth_session.id)
          unless data
            @reauth_session.errors.add(:base, "確認コードの再送信が必要です")
            return false
          end

          if Time.current.to_i > data["expires_at"].to_i
            @reauth_session.errors.add(:base, "確認コードの有効期限が切れました")
            return false
          end

          ok = verify_hotp_code(secret: data["secret"], counter: data["counter"], pass_code: code)
          session[EMAIL_OTP_SESSION_KEY].delete(@reauth_session.id) if ok
          ok
        end

        def prepare_passkey_challenge!
          allow_credentials = current_user.user_passkeys.map { |pk| { id: pk.webauthn_id } }
          if allow_credentials.empty?
            @reauth_session.errors.add(:base, "パスキーが登録されていません")
            return
          end

          @passkey_challenge_id, @passkey_request_options =
            create_authentication_challenge(allow_credentials: allow_credentials)
        end

        def verify_passkey!
          challenge_id = verification_params[:challenge_id].to_s
          credential_json = verification_params[:credential_json].to_s
          if challenge_id.blank? || credential_json.blank?
            @reauth_session.errors.add(:base, "パスキー認証データが不足しています")
            return false
          end

          credential_hash = JSON.parse(credential_json)

          with_challenge(challenge_id, purpose: :authentication) do |challenge|
            credential = WebAuthn::Credential.from_get(credential_hash, relying_party: webauthn_relying_party)
            passkey = UserPasskey.find_by(webauthn_id: Base64.urlsafe_encode64(credential.id, padding: false))
            unless passkey && passkey.user_id == current_user.id
              @reauth_session.errors.add(:base, I18n.t("errors.webauthn.credential_not_found"))
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
          @reauth_session.errors.add(:base, I18n.t("errors.webauthn.challenge_invalid"))
          false
        rescue WebAuthn::Error, JSON::ParserError
          @reauth_session.errors.add(:base, I18n.t("errors.webauthn.verification_failed"))
          false
        end

        def verify_success!
          now = Time.current
          ReauthSession.transaction do
            @reauth_session.update!(status: "VERIFIED", verified_at: now)
            @actor_token.update!(last_step_up_at: now, last_step_up_scope: @reauth_session.scope)
          end

          flash[:notice] = I18n.t("sign.app.verification.success.complete")
          jump_to_generated_url(@reauth_session.return_to, fallback: sign_app_configuration_path(ri: params[:ri]))
        end

        def render_verification_show(status: :unprocessable_content)
          @available_methods = available_step_up_methods
          @reauth_sessions = ReauthSession.for_actor(@actor_token).recent_first.limit(50)
          render "sign/app/verification/show", status: status
        end
      end
    end
  end
end
