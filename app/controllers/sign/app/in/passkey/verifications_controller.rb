# frozen_string_literal: true

module Sign
  module App
    module In
      module Passkey
        class VerificationsController < ApplicationController
          include Webauthn::SessionChallenge

          guest_only! status: :unauthorized,
                      message: I18n.t("sign.app.authentication.passkey.already_logged_in")

          # POST /in/passkey/verification
          # Verify WebAuthn authentication and establish session
          def create
            with_webauthn_challenge(purpose: "authentication", scope: "sign/app/in/passkey") do |challenge|
              credential = WebAuthn::Credential.from_get(credential_params.to_h)

              # Find passkey by credential ID (webauthn_id)
              passkey = UserPasskey.find_by(webauthn_id: credential.id)
              unless passkey
                Rails.logger.warn("WebAuthn: Unknown credential ID attempted")
                render json: { error: I18n.t("errors.webauthn.credential_not_found") }, status: :unauthorized
                return
              end

              # Verify the credential
              credential.verify(
                challenge,
                public_key: passkey.public_key,
                sign_count: passkey.sign_count,
                expected_origin: webauthn_origin,
              )

              # Update sign count and last used timestamp
              passkey.update!(
                sign_count: credential.sign_count,
              )

              # Establish user session using existing log_in mechanism
              user = passkey.user
              result = log_in(user, record_login_audit: true)

              case result[:status]
              when :totp_required
                render json: {
                  status: "totp_required",
                  redirect_url: new_sign_app_in_totp_path,
                }, status: :ok
              when :success
                render json: {
                  status: "ok",
                  access_token: result[:access_token],
                  token_type: result[:token_type],
                  expires_in: result[:expires_in],
                  redirect_url: sign_app_root_path,
                }, status: :ok
              else
                render json: { error: I18n.t("errors.login_failed") }, status: :unprocessable_content
              end
            end
          rescue Webauthn::SessionChallenge::ChallengeError => e
            Rails.logger.warn("WebAuthn challenge error during auth: #{e.message}")
            render json: { error: I18n.t("errors.webauthn.challenge_invalid") }, status: :bad_request
          rescue WebAuthn::SignCountVerificationError => e
            Rails.logger.warn("WebAuthn sign count verification failed: #{e.message}")
            render json: { error: I18n.t("errors.webauthn.sign_count_mismatch") }, status: :unauthorized
          rescue WebAuthn::Error => e
            Rails.logger.warn("WebAuthn authentication failed: #{e.message}")
            render json: { error: I18n.t("errors.webauthn.verification_failed") }, status: :unauthorized
          end

          private

          def credential_params
            params.expect(
              credential: [
                :id,
                :rawId,
                :type,
                :authenticatorAttachment,
                { response: %i(clientDataJSON authenticatorData signature userHandle) },
                { clientExtensionResults: {} },
              ],
            )
          end

          def webauthn_origin
            ENV.fetch("WEBAUTHN_ORIGIN_APP") { "https://#{ENV.fetch("SIGN_SERVICE_URL", "localhost")}" }
          end
        end
      end
    end
  end
end
