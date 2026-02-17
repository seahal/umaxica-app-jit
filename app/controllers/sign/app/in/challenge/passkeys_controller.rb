# frozen_string_literal: true

require "base64"

module Sign
  module App
    module In
      module Challenge
        class PasskeysController < ApplicationController
          include Sign::Webauthn
          include SessionLimitGate

          before_action :reject_logged_in_session
          before_action :ensure_pending_mfa!

          def new
            @mfa_user = pending_mfa_user
            passkeys = active_passkeys_for(@mfa_user)

            if passkeys.empty?
              redirect_to sign_app_in_challenge_path,
                          alert: I18n.t("errors.webauthn.no_passkeys_available"),
                          status: :see_other
              return
            end

            @passkey_challenge_id, @passkey_request_options =
              create_authentication_challenge(allow_credentials: passkeys.map { |pk| { id: pk.webauthn_id } })
          rescue Sign::Webauthn::OriginValidationError => e
            Rails.logger.error("WebAuthn origin validation failed: #{e.message}")
            redirect_to sign_app_in_challenge_path, alert: I18n.t("errors.webauthn.origin_invalid"), status: :see_other
          end

          def create
            with_challenge(passkey_params[:challenge_id], purpose: :authentication) do |challenge|
              verify_passkey!(challenge)
            end
          rescue Sign::Webauthn::ChallengeNotFoundError, Sign::Webauthn::ChallengeExpiredError,
                 Sign::Webauthn::ChallengePurposeMismatchError
            redirect_to sign_app_in_challenge_path, alert: I18n.t("errors.webauthn.challenge_invalid"),
                                                    status: :see_other
          rescue WebAuthn::SignCountVerificationError
            redirect_to sign_app_in_challenge_path, alert: I18n.t("errors.webauthn.sign_count_mismatch"),
                                                    status: :see_other
          rescue WebAuthn::Error
            redirect_to sign_app_in_challenge_path, alert: I18n.t("errors.webauthn.verification_failed"),
                                                    status: :see_other
          end

          private

          def ensure_pending_mfa!
            if !pending_mfa_valid? || pending_mfa_user.nil?
              clear_pending_mfa!
              redirect_to new_sign_app_in_path,
                          alert: I18n.t("sign.app.in.mfa.session_expired"),
                          status: :see_other
            end
          end

          def active_passkeys_for(user)
            user.user_passkeys.where(status_id: UserPasskeyStatus::ACTIVE)
          end

          def passkey_params
            params.fetch(:mfa_passkey_form, {}).permit(:challenge_id, :credential_json)
          end

          def verify_passkey!(challenge)
            credential_payload = JSON.parse(passkey_params[:credential_json].to_s)
            credential = WebAuthn::Credential.from_get(credential_payload)
            passkey = UserPasskey.find_by(webauthn_id: credential.id)

            user = pending_mfa_user
            unless passkey && user && passkey.user_id == user.id
              redirect_to sign_app_in_challenge_path,
                          alert: I18n.t("errors.webauthn.credential_not_found"),
                          status: :see_other
              return
            end

            with_webauthn_config do
              credential.verify(challenge, public_key: passkey.public_key, sign_count: passkey.sign_count)
            end
            passkey.update!(sign_count: credential.sign_count, last_used_at: Time.current)

            complete_mfa_login!(user)
          rescue JSON::ParserError
            redirect_to sign_app_in_challenge_path, alert: I18n.t("errors.webauthn.verification_failed"),
                                                    status: :see_other
          end

          def complete_mfa_login!(user)
            result = finalize_mfa_login!(user)
            case result[:status]
            when :session_limit_hard_reject
              render_session_limit_hard_reject(message: result[:message], http_status: result[:http_status])
            when :restricted
              redirect_to result[:redirect_path], notice: I18n.t("sign.app.in.session.restricted_notice")
            else
              issue_checkpoint!
              redirect_to sign_app_in_checkpoint_path(rd: result[:redirect_path], ri: params[:ri]),
                          notice: I18n.t("sign.app.in.mfa.passkey.success")
            end
          end
        end
      end
    end
  end
end
