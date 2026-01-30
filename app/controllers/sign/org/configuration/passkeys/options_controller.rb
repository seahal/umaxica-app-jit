# frozen_string_literal: true

module Sign
  module Org
    module Configuration
      module Passkeys
        class OptionsController < ApplicationController
          include Sign::Webauthn

          auth_required!

          # POST /configuration/passkeys/options
          # Generate WebAuthn registration options for creating a new staff passkey
          def create
            existing_credentials =
              current_staff.staff_passkeys.map do |passkey|
                { id: passkey.webauthn_id }
              end

            challenge_id, creation_options = create_registration_challenge(
              resource: current_staff,
              exclude_credentials: existing_credentials,
            )

            render json: {
              challenge_id: challenge_id,
              options: creation_options,
            }, status: :ok
          rescue Sign::Webauthn::OriginValidationError => e
            Rails.logger.error("WebAuthn origin validation failed: #{e.message}")
            render json: { error: I18n.t("errors.webauthn.origin_invalid") }, status: :forbidden
          rescue StandardError => e
            Rails.logger.error("WebAuthn options generation failed: #{e.message}")
            render json: { error: e.message }, status: :unprocessable_content
          end
        end
      end
    end
  end
end
