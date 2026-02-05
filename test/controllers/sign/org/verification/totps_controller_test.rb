# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::Org::Verification::TotpsControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @headers = as_staff_headers(@staff, host: @host)
    @token = StaffToken.create!(
      staff: @staff,
      staff_token_status_id: StaffTokenStatus::NEYO,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      public_id: "org_verify_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
    )
    @headers["X-TEST-SESSION-PUBLIC-ID"] = @token.public_id
  end

  test "create initializes a verification session" do
    return_to = Base64.urlsafe_encode64(sign_org_configuration_path(ri: "jp"))

    post sign_org_verification_totp_url(ri: "jp"),
         params: { verification: { scope: "configuration_email", return_to: return_to } },
         headers: @headers

    assert_response :redirect
    reauth_session = ReauthSession.order(created_at: :desc).first
    assert_equal "totp", reauth_session.method
    assert_equal @token.id, reauth_session.actor_id
  end

  test "should get new" do
    reauth_session = ReauthSession.create!(
      actor: @token,
      scope: "configuration_email",
      return_to: Base64.urlsafe_encode64(sign_org_configuration_path(ri: "jp")),
      method: "totp",
      status: "PENDING",
      expires_at: 10.minutes.from_now,
    )

    get new_sign_org_verification_totp_url(session_id: reauth_session.id, ri: "jp"), headers: @headers
    assert_response :success
  end
end
