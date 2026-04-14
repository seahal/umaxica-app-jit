# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::App::Verification::PasskeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = as_user_headers(@user, host: @host)
    @token = UserToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
    UserEmail.create!(
      user: @user,
      address: "verified-#{SecureRandom.hex(4)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
      otp_private_key: "otp_private_key",
      otp_counter: "0",
    )
    @passkey = UserPasskey.create!(
      user: @user,
      webauthn_id: Base64.urlsafe_encode64("step_up_passkey_id_1", padding: false),
      external_id: SecureRandom.uuid,
      public_key: "step_up_passkey_public_key",
      description: "Step-up Passkey",
      status_id: UserPasskeyStatus::ACTIVE,
    )
  end

  test "creates verification on success" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))
    trusted_origins = [
      "http://sign.app.localhost",
      "https://sign.app.localhost",
      "http://sign.app.localhost:3000",
      "https://sign.app.localhost:3000",
    ]

    Webauthn.stub(:trusted_origins, trusted_origins) do
      get sign_app_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
          headers: @headers

      get new_sign_app_verification_passkey_url(ri: "jp"), headers: @headers

      assert_response :success

      challenge_id = session[:passkey_challenges].keys.first
      passkey_id = @passkey.webauthn_id
      mock_credential = Object.new
      mock_credential.define_singleton_method(:id) { passkey_id }
      mock_credential.define_singleton_method(:sign_count) { 1 }
      mock_credential.define_singleton_method(:verify) { |*_args| true }

      WebAuthn::Credential.stub(:from_get, mock_credential) do
        post sign_app_verification_passkey_url(ri: "jp"), params: {
          verification: {
            challenge_id: challenge_id,
            credential_json: {
              id: passkey_id,
              type: "public-key",
              response: {
                clientDataJSON: "e30=",
                authenticatorData: "e30=",
                signature: "sig",
                userHandle: @user.public_id,
              },
            }.to_json,
          },
        }, headers: @headers
      end
    end

    assert_response :redirect
    assert_redirected_to sign_app_configuration_emails_url(ri: "jp")
  end

  test "new keeps scope and return_to in form hidden fields" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))
    trusted_origins = [
      "http://sign.app.localhost",
      "https://sign.app.localhost",
      "http://sign.app.localhost:3000",
      "https://sign.app.localhost:3000",
    ]

    Webauthn.stub(:trusted_origins, trusted_origins) do
      get sign_app_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
          headers: @headers

      get new_sign_app_verification_passkey_url(
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
