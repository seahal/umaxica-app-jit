# frozen_string_literal: true

require "json"

module Sign
  module Org
    module Verification
      class BaseController < ApplicationController
        include Common::Otp
        include Sign::Webauthn

        auth_required!

        before_action :authenticate_staff!
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
          safe = generate_redirect_url(decoded)
          raise ArgumentError, "unsafe return_to" if safe.blank?

          safe
        rescue ArgumentError
          raise
        end

        def verify_totp!
          code = verification_params[:code].to_s
          unless code.match?(/\A\d{6}\z/)
            @reauth_session.errors.add(:base, "確認コードが不正です")
            return false
          end

          totps =
            current_staff.staff_one_time_passwords
              .where(staff_one_time_password_status_id: StaffOneTimePasswordStatus::ACTIVE)
              .order(created_at: :desc)

          totps.any? do |totp|
            ROTP::TOTP.new(totp.private_key).verify(code)
          end
        end

        def prepare_passkey_challenge!
          allow_credentials = current_staff.staff_passkeys.map { |pk| { id: pk.webauthn_id } }
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
            passkey = StaffPasskey.find_by(webauthn_id: Base64.urlsafe_encode64(credential.id, padding: false))
            unless passkey && passkey.staff_id == current_staff.id
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

          flash[:notice] = I18n.t("sign.org.verification.success.complete")
          jump_to_generated_url(@reauth_session.return_to, fallback: sign_org_configuration_path(ri: params[:ri]))
        end

        def render_verification_show(status: :unprocessable_content)
          @reauth_sessions = ReauthSession.for_actor(@actor_token).recent_first.limit(50)
          render "sign/org/verification/show", status: status
        end
      end
    end
  end
end
