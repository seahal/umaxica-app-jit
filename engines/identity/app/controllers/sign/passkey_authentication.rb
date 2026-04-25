# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module PasskeyAuthentication
        extend ActiveSupport::Concern

        private

        def build_authentication_credential
          WebAuthn::Credential.from_get(credential_params.to_h)
        rescue StandardError => e
          Rails.event.warn("webauthn.invalid_credential_payload", error_class: e.class.name)
          render_error("errors.webauthn.credential_not_found", :unauthorized)
          nil
        end

        def verify_authentication_credential!(credential:, passkey:, challenge:)
          with_webauthn_config do
            credential.verify(
              challenge,
              public_key: passkey.public_key,
              sign_count: passkey.sign_count,
            )
          end

          attrs = { sign_count: credential.sign_count }
          attrs[:last_used_at] = Time.current if passkey.has_attribute?(:last_used_at)
          passkey.update!(attrs)
        end
      end
    end
  end
end
