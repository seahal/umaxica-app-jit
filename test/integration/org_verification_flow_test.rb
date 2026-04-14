# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

# Integration tests for Org verification flow
#
# These tests verify:
# - Org staff verification flow works similarly to App
# - Email OTP is NOT available for Org (passkey only)
# - High-risk operations require verification
#
class OrgVerificationFlowTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses, :staff_passkeys, :staff_passkey_statuses

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @token = StaffToken.create!(
      staff: @staff,
      staff_token_status_id: StaffTokenStatus::NOTHING,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      public_id: "ovf#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
    )
    @headers = as_staff_headers(@staff, host: @host)
    @headers["X-TEST-SESSION-PUBLIC-ID"] = @token.public_id
  end

  test "org verification show page does not display email option" do
    StaffPasskey.create!(
      staff: @staff,
      webauthn_id: Base64.urlsafe_encode64("org_verification_show_passkey_#{SecureRandom.hex(4)}", padding: false),
      external_id: SecureRandom.uuid,
      public_key: "org_verification_show_passkey_public_key",
      name: "Verification Passkey",
      status_id: StaffPasskeyStatus::ACTIVE,
    )

    get sign_org_verification_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_select "a", text: I18n.t("sign.org.verification.new.methods.passkey")
    assert_no_match(/email/i, response.body)
  end

  test "org can verify with passkey" do
    passkey = StaffPasskey.create!(
      staff: @staff,
      webauthn_id: Base64.urlsafe_encode64("org_verification_passkey_#{SecureRandom.hex(4)}", padding: false),
      external_id: SecureRandom.uuid,
      public_key: "org_verification_passkey_public_key",
      name: "Verification Passkey",
      status_id: StaffPasskeyStatus::ACTIVE,
    )
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
      mock_credential = Object.new
      mock_credential.define_singleton_method(:id) { passkey.webauthn_id }
      mock_credential.define_singleton_method(:sign_count) { 1 }
      mock_credential.define_singleton_method(:verify) { |*_args| true }

      WebAuthn::Credential.stub(:from_get, mock_credential) do
        post sign_org_verification_passkey_url(ri: "jp"), params: {
          verification: {
            challenge_id: challenge_id,
            credential_json: {
              id: passkey.webauthn_id,
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
    assert_not_nil @token.reload.last_step_up_at
    assert_equal "configuration_passkey", @token.last_step_up_scope
  end
end
