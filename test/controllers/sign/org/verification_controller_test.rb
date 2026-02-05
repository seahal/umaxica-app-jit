# frozen_string_literal: true

require "test_helper"

class Sign::Org::VerificationControllerTest < ActionDispatch::IntegrationTest
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

  test "should get show" do
    get sign_org_verification_url(ri: "jp"), headers: @headers
    assert_response :success
  end
end
