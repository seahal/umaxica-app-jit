# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class OrgVerificationTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_one_time_password_statuses

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    host! @host

    @staff = staffs(:one)

    @token = StaffToken.create!(
      staff: @staff,
      staff_token_status_id: StaffTokenStatus::NEYO,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      public_id: "org_verify_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
    )
    @token.update!(created_at: 1.hour.ago)

    @headers = {
      "X-TEST-CURRENT-STAFF" => @staff.id.to_s,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }.freeze
  end

  test "verify success updates token step-up and redirects to return_to" do
    private_key = "JBSWY3DPEHPK3PXP"
    StaffOneTimePassword.create!(
      staff: @staff,
      private_key: private_key,
      staff_one_time_password_status_id: StaffOneTimePasswordStatus::ACTIVE,
    )

    encoded_return_to = Base64.urlsafe_encode64(sign_org_configuration_totps_path(ri: "jp"))
    get sign_org_verification_url(scope: "manage_totp", return_to: encoded_return_to, ri: "jp"),
        headers: @headers

    code = ROTP::TOTP.new(private_key).at(Time.current.to_i)

    post sign_org_verification_totp_url(ri: "jp"),
         params: { verification: { code: code } },
         headers: @headers

    assert_response :redirect
    assert_redirected_to sign_org_configuration_totps_url(ri: "jp")
    # assert_redirected_to sign_org_configuration_url(ri: "jp")

    @token.reload
    assert_not_nil @token.last_step_up_at
    assert_equal "manage_totp", @token.last_step_up_scope
  end

  test "verify failure returns 422" do
    private_key = "JBSWY3DPEHPK3PXP"
    StaffOneTimePassword.create!(
      staff: @staff,
      private_key: private_key,
      staff_one_time_password_status_id: StaffOneTimePasswordStatus::ACTIVE,
    )

    encoded_return_to = Base64.urlsafe_encode64(sign_org_configuration_totps_path(ri: "jp"))
    get sign_org_verification_url(scope: "manage_totp", return_to: encoded_return_to, ri: "jp"),
        headers: @headers

    post sign_org_verification_totp_url(ri: "jp"),
         params: { verification: { code: "000000" } },
         headers: @headers

    # assert_response :redirect
    assert_response :unprocessable_content
  end
end
