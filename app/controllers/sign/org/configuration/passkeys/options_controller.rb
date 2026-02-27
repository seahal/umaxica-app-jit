# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Configuration
      module Passkeys
        class OptionsController < ApplicationController
          include Webauthn::SessionChallenge

          auth_required!

          # POST /configuration/passkeys/options
          # Generate WebAuthn registration options for creating a new staff passkey
          def create
            creation_options = WebAuthn::Credential.options_for_create(
              user: {
                id: current_staff.public_id,
                name: primary_staff_email || "staff@example.com",
                display_name: primary_staff_name || I18n.t("sign.default_staff_name"),
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
              scope: "sign/org/configuration/passkeys",
              challenge: creation_options.challenge,
            )

            render json: creation_options, status: :ok
          rescue WebAuthn::Error => e
            Rails.logger.error("WebAuthn options generation failed: #{e.message}")
            render json: { error: e.message }, status: :unprocessable_content
          end

          private

          def primary_staff_email
            current_staff.staff_emails.first&.address
          end

          def primary_staff_name
            current_staff.try(:name) || primary_staff_email
          end

          def webauthn_rp_id
            ENV.fetch("WEBAUTHN_RP_ID_ORG") { URI.parse(ENV.fetch("SIGN_STAFF_URL", "localhost")).host }
          end

          def webauthn_rp_name
            ENV.fetch("WEBAUTHN_RP_NAME_ORG", "Umaxica Org")
          end
        end
      end
    end
  end
end
