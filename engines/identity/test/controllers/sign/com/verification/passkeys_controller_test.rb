# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    require "test_helper"
    require "base64"

    class Sign::Com::Verification::PasskeysControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV.fetch("IDENTITY_SIGN_COM_URL", "sign.com.localhost")
        host! @host
        @customer = create_verified_customer_with_email(
          email_address: "com-passkey-stepup-#{SecureRandom.hex(4)}@example.com",
        )
        @customer.customer_telephones.create!(
          number: "+8190#{SecureRandom.random_number(10**8).to_s.rjust(8, "0")}",
          customer_telephone_status_id: CustomerTelephoneStatus::VERIFIED,
        )
        @headers = as_customer_headers(@customer, host: @host)
        @token = CustomerToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
        @passkey = CustomerPasskey.create!(
          customer: @customer,
          webauthn_id: Base64.urlsafe_encode64("com_step_up_passkey_id_1", padding: false),
          external_id: SecureRandom.uuid,
          public_key: "com_step_up_passkey_public_key",
          description: "Step-up Passkey",
          status_id: CustomerPasskeyStatus::ACTIVE,
        )
      end

      test "creates verification on success" do
        return_to = Base64.urlsafe_encode64(sign_com_configuration_emails_path(ri: "jp"))
        trusted_origins = [
          "http://#{@host}",
          "https://#{@host}",
          "http://#{@host}:3000",
          "https://#{@host}:3000",
          "http://sign.app.localhost",
          "https://sign.app.localhost",
        ]

        Webauthn.stub(:trusted_origins, trusted_origins) do
          get sign_com_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
              headers: @headers

          get new_sign_com_verification_passkey_url(ri: "jp"), headers: @headers

          assert_response :success

          challenge_id = session[:passkey_challenges].keys.first
          passkey_id = @passkey.webauthn_id
          mock_credential = Object.new
          mock_credential.define_singleton_method(:id) { passkey_id }
          mock_credential.define_singleton_method(:sign_count) { 1 }
          mock_credential.define_singleton_method(:verify) { |*_args| true }

          WebAuthn::Credential.stub(:from_get, mock_credential) do
            post sign_com_verification_passkey_url(ri: "jp"), params: {
              verification: {
                challenge_id: challenge_id,
                credential_json: {
                  id: passkey_id,
                  type: "public-key",
                  response: {
                    clientDataJSON: "e30=",
                    authenticatorData: "e30=",
                    signature: "sig",
                    userHandle: @customer.public_id,
                  },
                }.to_json,
              },
            }, headers: @headers
          end
        end

        assert_response :redirect
        assert_redirected_to sign_com_configuration_emails_url(ri: "jp")
      end

      test "new keeps scope and return_to in form hidden fields" do
        return_to = Base64.urlsafe_encode64(sign_com_configuration_emails_path(ri: "jp"))
        trusted_origins = [
          "http://#{@host}",
          "https://#{@host}",
          "http://#{@host}:3000",
          "https://#{@host}:3000",
          "http://sign.app.localhost",
          "https://sign.app.localhost",
        ]

        Webauthn.stub(:trusted_origins, trusted_origins) do
          get sign_com_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
              headers: @headers

          get new_sign_com_verification_passkey_url(
            ri: "jp",
            scope: "configuration_email",
            return_to: return_to,
          ), headers: @headers
        end

        assert_response :success
        assert_select "input[name='verification[scope]'][value='configuration_email']"
        assert_select "input[name='verification[return_to]'][value='#{return_to}']"
      end
    end
  end
end
