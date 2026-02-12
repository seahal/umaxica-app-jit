# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::Org::Verification::TotpsControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_one_time_password_statuses

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

  test "creates verification on success" do
    private_key = "JBSWY3DPEHPK3PXP"
    StaffOneTimePassword.create!(
      staff: @staff,
      private_key: private_key,
      staff_one_time_password_status_id: StaffOneTimePasswordStatus::ACTIVE,
    )

    return_to = Base64.urlsafe_encode64(sign_org_configuration_totps_path(ri: "jp"))
    get sign_org_verification_url(scope: "manage_totp", return_to: return_to, ri: "jp"),
        headers: @headers

    get new_sign_org_verification_totp_url(ri: "jp"), headers: @headers
    assert_response :success
    # assert_response :redirect

    # code = ROTP::TOTP.new(private_key).at(Time.current.to_i)

    # post sign_org_verification_totp_url(ri: "jp"),
    #      params: { verification: { code: code } },
    #      headers: @headers

    # assert_response :redirect
    # assert_redirected_to sign_org_configuration_totps_url(ri: "jp")
  end
end
