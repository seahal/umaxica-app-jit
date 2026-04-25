# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    require "test_helper"
    require "base64"

    class Sign::Org::Verification::PasskeysControllerTest < ActionDispatch::IntegrationTest
      fixtures :staffs, :staff_tokens

      setup do
        @host = ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
        @staff = staffs(:one)
        @headers = as_staff_headers(@staff, host: @host)
        @token = staff_tokens(:one)
        @headers["X-TEST-SESSION-PUBLIC-ID"] = @token.public_id
        @staff_passkey = StaffPasskey.create!(
          staff: @staff,
          webauthn_id: Base64.urlsafe_encode64("staff_step_up_passkey_id_1", padding: false),
          external_id: SecureRandom.uuid,
          public_key: "staff_step_up_passkey_public_key",
          name: "Step-up Passkey",
          status_id: StaffPasskeyStatus::ACTIVE,
        )
      end

      test "creates verification on success" do
        return_to = Base64.urlsafe_encode64(sign_org_configuration_passkeys_path(ri: "jp"))
        trusted_origins = [
          "http://#{@host}",
          "https://#{@host}",
          "http://#{@host}:3000",
          "https://#{@host}:3000",
          "http://sign.app.localhost",
          "https://sign.app.localhost",
        ]

        Webauthn.stub(:trusted_origins, trusted_origins) do
          get sign_org_verification_url(scope: "configuration_passkey", return_to: return_to, ri: "jp"),
              headers: @headers

          get new_sign_org_verification_passkey_url(ri: "jp"), headers: @headers

          assert_response :success

          challenge_id = session[:passkey_challenges].keys.first
          passkey_id = @staff_passkey.webauthn_id
          mock_credential = Object.new
          mock_credential.define_singleton_method(:id) { passkey_id }
          mock_credential.define_singleton_method(:sign_count) { 1 }
          mock_credential.define_singleton_method(:verify) { |*_args| true }

          WebAuthn::Credential.stub(:from_get, mock_credential) do
            post sign_org_verification_passkey_url(ri: "jp"), params: {
              verification: {
                challenge_id: challenge_id,
                credential_json: {
                  id: passkey_id,
                  type: "public-key",
                  response: {
                    clientDataJSON: "e30=",
                    authenticatorData: "e30=",
                    signature: "sig",
                    userHandle: @staff.public_id,
                  },
                }.to_json,
              },
            }, headers: @headers
          end
        end

        assert_response :redirect
        assert_redirected_to sign_org_configuration_passkeys_url(ri: "jp")

        @token.reload

        assert_not_nil @token.last_step_up_at
        assert_equal "configuration_passkey", @token.last_step_up_scope
        assert_nil session[:reauth]
      end
    end
  end
end
