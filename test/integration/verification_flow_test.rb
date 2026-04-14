# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

# Integration tests for verification flow
#
# These tests verify:
# - High-risk operations require verification (step-up auth)
# - After successful verification, user is redirected to return_to
#
class VerificationFlowTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_tokens

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    UserEmail.create!(user: @user, address: "vf_#{SecureRandom.hex(4)}@example.com", user_email_status_id: UserEmailStatus::VERIFIED)
    @token = UserToken.create!(
      user: @user,
      user_token_status_id: UserTokenStatus::NOTHING,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
      public_id: "vf#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
    )
    @headers = as_user_headers(@user, host: @host)
    @headers["X-TEST-SESSION-PUBLIC-ID"] = @token.public_id
  end

  test "high-risk operation redirects to verification when step-up not satisfied" do
    # Make token old enough to require step-up
    @token.update!(created_at: 1.hour.ago)

    # Try to access email configuration (requires step-up)
    get sign_app_configuration_emails_url(ri: "jp"), headers: @headers

    assert_response :redirect
    assert_match %r{/verification}, response.location
    assert_match(/scope=configuration_email/, response.location)
    assert_match(/rd=/, response.location)
  end

  test "high-risk operation redirects to verification when step-up not satisfied (HEAD)" do
    # Make token old enough to require step-up
    @token.update!(created_at: 1.hour.ago)

    # Try to access email configuration (requires step-up)
    head sign_app_configuration_emails_url(ri: "jp"), headers: @headers

    assert_response :redirect
    assert_match %r{/verification}, response.location
    assert_match(/scope=configuration_email/, response.location)
    assert_match(/rd=/, response.location)
  end

  test "successful passkey verification redirects to return_to" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))
    passkey = UserPasskey.create!(
      user: @user,
      webauthn_id: Base64.urlsafe_encode64("verification_flow_passkey_#{SecureRandom.hex(4)}", padding: false),
      external_id: SecureRandom.uuid,
      public_key: "verification_flow_passkey_public_key",
      description: "Verification Passkey",
      status_id: UserPasskeyStatus::ACTIVE,
    )
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
      mock_credential = Object.new
      mock_credential.define_singleton_method(:id) { passkey.webauthn_id }
      mock_credential.define_singleton_method(:sign_count) { 1 }
      mock_credential.define_singleton_method(:verify) { |*_args| true }

      WebAuthn::Credential.stub(:from_get, mock_credential) do
        post sign_app_verification_passkey_url(ri: "jp"), params: {
          verification: {
            challenge_id: challenge_id,
            credential_json: {
              id: passkey.webauthn_id,
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
end
