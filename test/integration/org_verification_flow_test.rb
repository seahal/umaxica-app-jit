# frozen_string_literal: true

require "test_helper"

# Integration tests for Org verification flow
#
# These tests verify:
# - Org staff verification flow works similarly to App
# - Email OTP is NOT available for Org (only passkey and totp)
# - High-risk operations require verification
class OrgVerificationFlowTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @token = StaffToken.create!(
      staff: @staff,
      staff_token_status_id: StaffTokenStatus::NEYO,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      public_id: "ovf#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
    )
    @headers = as_staff_headers(@staff, host: @host)
    @headers["X-TEST-SESSION-PUBLIC-ID"] = @token.public_id
  end

  test "org verification show page does not display email option" do
    get sign_org_verification_url(ri: "jp"), headers: @headers
    assert_response :success

    # Should have passkey and totp buttons
    assert_select "form[action=?]", sign_org_verification_passkey_path(ri: "jp")
    assert_select "form[action=?]", sign_org_verification_totp_path(ri: "jp")

    # Should NOT have email button (no emails route for org)
    assert_select "form[action*='email']", count: 0
  end

  test "org can create passkey verification session" do
    return_to_path = sign_org_configuration_path(ri: "jp")
    return_to_encoded = Base64.urlsafe_encode64(return_to_path)

    assert_difference "ReauthSession.count", 1 do
      post sign_org_verification_passkey_url(ri: "jp"),
           params: { verification: { scope: "configuration_passkey", return_to: return_to_encoded } },
           headers: @headers
    end

    assert_response :redirect
    reauth_session = ReauthSession.order(created_at: :desc).first
    assert_equal "passkey", reauth_session.method
    assert_equal "PENDING", reauth_session.status
    assert_equal @token.id, reauth_session.actor_id
  end

  test "org can create totp verification session" do
    return_to_path = sign_org_configuration_path(ri: "jp")
    return_to_encoded = Base64.urlsafe_encode64(return_to_path)

    assert_difference "ReauthSession.count", 1 do
      post sign_org_verification_totp_url(ri: "jp"),
           params: { verification: { scope: "configuration_totp", return_to: return_to_encoded } },
           headers: @headers
    end

    assert_response :redirect
    reauth_session = ReauthSession.order(created_at: :desc).first
    assert_equal "totp", reauth_session.method
    assert_equal "PENDING", reauth_session.status
  end

  test "expired org verification session returns 410 Gone" do
    reauth_session = ReauthSession.create!(
      actor: @token,
      scope: "configuration_passkey",
      return_to: sign_org_configuration_path(ri: "jp"),
      method: "passkey",
      status: "PENDING",
      expires_at: 1.minute.ago, # Expired
    )

    get new_sign_org_verification_passkey_url(session_id: reauth_session.id, ri: "jp"),
        headers: @headers
    assert_response :gone
  end
end
