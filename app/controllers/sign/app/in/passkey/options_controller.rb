# frozen_string_literal: true

module Sign
  module App
    module In
      module Passkey
        class OptionsController < ApplicationController
          include Webauthn::SessionChallenge

          guest_only! status: :bad_request,
                      message: I18n.t("sign.app.authentication.passkey.already_logged_in")

          # POST /in/passkey/options
          # Generate WebAuthn authentication (get) options for login
          def create
            request_options = WebAuthn::Credential.options_for_get(
              allow_credentials: [], # Empty = allow any registered credential (discoverable)
              user_verification: "preferred",
              rp_id: webauthn_rp_id,
            )

            store_webauthn_challenge!(
              purpose: "authentication",
              scope: "sign/app/in/passkey",
              challenge: request_options.challenge,
            )

            render json: request_options, status: :ok
          rescue WebAuthn::Error => e
            Rails.logger.error("WebAuthn authentication options failed: #{e.message}")
            render json: { error: e.message }, status: :unprocessable_content
          end

          private

          def webauthn_rp_id
            ENV.fetch("WEBAUTHN_RP_ID_APP") { URI.parse(ENV.fetch("SIGN_SERVICE_URL", "localhost")).host }
          end
        end
      end
    end
  end
end
