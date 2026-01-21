# frozen_string_literal: true

module Sign
  module Org
    module Configuration
      module Passkeys
        class VerificationsController < ApplicationController
          include Webauthn::SessionChallenge

          auth_required!

          # POST /configuration/passkeys/verification
          # Verify and complete WebAuthn registration for staff
          def create
            with_webauthn_challenge(purpose: "registration", scope: "sign/org/configuration/passkeys") do |challenge|
              credential = WebAuthn::Credential.from_create(credential_params.to_h)
              credential.verify(challenge, expected_origin: webauthn_origin)

              passkey = current_staff.staff_passkeys.new(
                webauthn_id: credential.id,
                public_key: credential.public_key,
                sign_count: credential.sign_count,
                external_id: SecureRandom.uuid,
                description: passkey_description,
              )

              authorize passkey, :create?
              passkey.save!

              render json: {
                status: "ok",
                passkey_id: passkey.id,
                redirect_url: sign_org_configuration_passkeys_path,
              }, status: :created
            end
          rescue Webauthn::SessionChallenge::ChallengeError => e
            Rails.logger.warn("WebAuthn challenge error: #{e.message}")
            render json: { error: I18n.t("errors.webauthn.challenge_invalid") }, status: :bad_request
          rescue WebAuthn::Error => e
            Rails.logger.warn("WebAuthn verification failed: #{e.message}")
            render json: { error: e.message }, status: :unprocessable_content
          rescue ActiveRecord::RecordInvalid => e
            render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_content
          end

          private

          def credential_params
            params.expect(
              credential: [
                :id,
                :rawId,
                :type,
                :authenticatorAttachment,
                { transports: [] },
                { response: [:clientDataJSON, :attestationObject] },
                { clientExtensionResults: {} },
              ],
            )
          end

          def passkey_description
            params[:description].presence || I18n.t("sign.default_passkey_description")
          end

          def webauthn_origin
            ENV.fetch("WEBAUTHN_ORIGIN_ORG") { "https://#{ENV.fetch("SIGN_STAFF_URL", "localhost")}" }
          end
        end
      end
    end
  end
end
