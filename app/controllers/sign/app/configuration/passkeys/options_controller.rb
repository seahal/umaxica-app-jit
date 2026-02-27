# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Configuration
      module Passkeys
        class OptionsController < ApplicationController
          include Webauthn::SessionChallenge

          auth_required!

          # POST /configuration/passkeys/options
          # Generate WebAuthn registration options for creating a new passkey
          def create
            creation_options = WebAuthn::Credential.options_for_create(
              user: {
                id: current_user.public_id,
                name: primary_user_email || "user@example.com",
                display_name: primary_user_name || I18n.t("sign.default_user_name"),
              },
              authenticator_selection: {
                user_verification: "preferred",
                resident_key: "preferred",
              },
              attestation: "none",
              rp: {
                id: webauthn_rp_id,
                name: webauthn_rp_name,
              },
            )

            store_webauthn_challenge!(
              purpose: "registration",
              scope: "sign/app/configuration/passkeys",
              challenge: creation_options.challenge,
            )

            render json: creation_options, status: :ok
          rescue WebAuthn::Error => e
            Rails.logger.error("WebAuthn options generation failed: #{e.message}")
            render json: { error: e.message }, status: :unprocessable_content
          end

          private

          def primary_user_email
            current_user.user_emails.first&.address
          end

          def primary_user_name
            current_user.try(:name) || primary_user_email
          end

          def webauthn_rp_id
            ENV.fetch("WEBAUTHN_RP_ID_APP") { URI.parse(ENV.fetch("SIGN_SERVICE_URL", "localhost")).host }
          end

          def webauthn_rp_name
            ENV.fetch("WEBAUTHN_RP_NAME_APP", "Umaxica App")
          end
        end
      end
    end
  end
end
