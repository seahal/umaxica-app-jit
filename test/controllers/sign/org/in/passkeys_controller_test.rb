# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "base64"

class Sign::Org::In::PasskeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses, :staff_passkeys, :staff_passkey_statuses

  setup do
    host! ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @original_trusted_origins = Webauthn.method(:trusted_origins)
    Webauthn.define_singleton_method(:trusted_origins) { ["http://sign.app.localhost", "http://sign.org.localhost"] }

    # Setup active staff with email and passkey
    @staff = staffs(:one)
    @staff.update!(status_id: StaffStatus::ACTIVE)

    @staff_email = StaffEmail.create!(
      staff: @staff,
      address: "staff_test@example.com",
      staff_email_status_id: StaffEmailStatus::VERIFIED,
    )

    @staff_passkey = StaffPasskey.create!(
      staff: @staff,
      webauthn_id: Base64.urlsafe_encode64("staff_login_id_bytes_12345", padding: false),
      external_id: SecureRandom.uuid,
      public_key: "staff_login_key",
      name: "Staff Login Key",
      status_id: StaffPasskeyStatus::ACTIVE,
    )
  end

  teardown do
    Webauthn.define_singleton_method(:trusted_origins, @original_trusted_origins)
  end

  test "should get new" do
    get new_sign_org_in_passkey_url(ri: "jp")
    assert_response :success
  end

  test "options returns error if identifier blank" do
    post options_sign_org_in_passkeys_url(ri: "jp"), params: { identifier: "" }

    assert_response :unprocessable_content
    assert_includes response.body, I18n.t("errors.webauthn.identifier_required")
  end

  test "options returns error if identifier not found" do
    post options_sign_org_in_passkeys_url(ri: "jp"), params: { identifier: "unknown@example.com" }

    assert_response :unprocessable_content
    assert_includes response.body, I18n.t("errors.webauthn.no_passkeys_available")
  end

  test "options returns error if staff has no passkeys" do
    staff_no_passkey = staffs(:two)
    staff_no_passkey.update!(status_id: StaffStatus::ACTIVE)
    StaffEmail.create!(
      staff: staff_no_passkey,
      address: "nopasskey_staff@example.com",
      staff_email_status_id: StaffEmailStatus::VERIFIED,
    )

    post options_sign_org_in_passkeys_url(ri: "jp"), params: { identifier: "nopasskey_staff@example.com" }

    assert_response :unprocessable_content
    assert_includes response.body, I18n.t("errors.webauthn.no_passkeys_available")
  end

  test "options returns challenge and allowCredentials for email identifier" do
    post options_sign_org_in_passkeys_url(ri: "jp"), params: { identifier: @staff_email.address }

    assert_response :ok
    json = response.parsed_body

    assert_not_nil json["challenge_id"]
    options = json["options"]
    assert_not_empty options["allowCredentials"]

    # Verify allowCredentials contains our passkey ID
    match = options["allowCredentials"].any? { |c| c["id"] == @staff_passkey.webauthn_id }
    assert match, "Expected allowCredentials to contain #{@staff_passkey.webauthn_id}"

    # Verify challenge saved with correct purpose
    assert_not_nil session[:passkey_challenges][json["challenge_id"]]
    assert_equal "authentication", session[:passkey_challenges][json["challenge_id"]]["purpose"]
    assert_equal @staff.id, session[:passkey_challenges][json["challenge_id"]]["staff_id"]
  end

  test "options returns challenge and allowCredentials for staff_code identifier" do
    post options_sign_org_in_passkeys_url(ri: "jp"), params: { identifier: @staff.public_id }

    assert_response :ok
    json = response.parsed_body
    assert_not_nil json["challenge_id"]
    assert_not_empty json.dig("options", "allowCredentials")
  end

  test "verification returns error if challenge_id blank" do
    post verification_sign_org_in_passkeys_url(ri: "jp"), params: { challenge_id: "" }

    assert_response :bad_request
    assert_includes response.body, I18n.t("errors.webauthn.challenge_id_required")
  end

  test "verification returns error if challenge invalid" do
    post verification_sign_org_in_passkeys_url(ri: "jp"), params: { challenge_id: "invalid_challenge" }

    assert_response :bad_request
    assert_includes response.body, I18n.t("errors.webauthn.challenge_invalid")
  end

  test "verification logs staff in on success" do
    assert_not_nil @staff_passkey, "Passkey must exist"
    # Get challenge
    email = StaffEmail.find_by(staff: @staff).address
    post options_sign_org_in_passkeys_url(ri: "jp"), params: { identifier: email }
    explanation = response.parsed_body
    challenge_id = explanation["challenge_id"]

    # Mock WebAuthn verification
    mock_credential = Object.new
    passkey_id = @staff_passkey.webauthn_id
    mock_credential.define_singleton_method(:id) { passkey_id }
    mock_credential.define_singleton_method(:sign_count) { 1 }
    mock_credential.define_singleton_method(:verify) { |*_args| true }

    WebAuthn::Credential.stub :from_get, mock_credential do
      params = {
        challenge_id: challenge_id,
        credential: {
          id: @staff_passkey.webauthn_id,
          response: { clientDataJSON: "e30=", authenticatorData: "e30=", signature: "sig", userHandle: "h" },
        },
      }

      # Should log in
      post verification_sign_org_in_passkeys_url(ri: "jp"), params: params

      assert_response :ok
      json = response.parsed_body
      assert_equal "ok", json["status"]
      assert_not_nil json["access_token"]

      # Challenge verification updates sign count
      assert_equal 1, @staff_passkey.reload.sign_count
    end
  end

  test "verification returns unauthorized for credential mismatch" do
    post options_sign_org_in_passkeys_url(ri: "jp"), params: { identifier: @staff_email.address }
    challenge_id = response.parsed_body["challenge_id"]

    mock_credential = Object.new
    mock_credential.define_singleton_method(:id) { Base64.urlsafe_encode64("unknown_credential", padding: false) }
    mock_credential.define_singleton_method(:sign_count) { 1 }
    mock_credential.define_singleton_method(:verify) { |*_args| true }

    WebAuthn::Credential.stub :from_get, mock_credential do
      post verification_sign_org_in_passkeys_url(ri: "jp"), params: {
        challenge_id: challenge_id,
        credential: {
          id: Base64.urlsafe_encode64("unknown_credential", padding: false),
          response: { clientDataJSON: "e30=", authenticatorData: "e30=", signature: "sig", userHandle: "h" },
        },
      }

      assert_response :unauthorized
      assert_includes response.body, I18n.t("errors.webauthn.credential_not_found")
    end
  end

  test "verification for staff with mfa enabled succeeds (MFA not enforced for staff)" do
    @staff.update!(multi_factor_enabled: true)

    post options_sign_org_in_passkeys_url(ri: "jp"), params: { identifier: @staff_email.address }
    challenge_id = response.parsed_body["challenge_id"]

    mock_credential = Object.new
    passkey_id = @staff_passkey.webauthn_id
    mock_credential.define_singleton_method(:id) { passkey_id }
    mock_credential.define_singleton_method(:sign_count) { 1 }
    mock_credential.define_singleton_method(:verify) { |*_args| true }

    WebAuthn::Credential.stub :from_get, mock_credential do
      params = {
        challenge_id: challenge_id,
        credential: {
          id: @staff_passkey.webauthn_id,
          response: { clientDataJSON: "e30=", authenticatorData: "e30=", signature: "sig", userHandle: "h" },
        },
      }

      post verification_sign_org_in_passkeys_url(ri: "jp"), params: params

      assert_response :ok
      json = response.parsed_body
      assert_equal "ok", json["status"]
    end
  end
end
