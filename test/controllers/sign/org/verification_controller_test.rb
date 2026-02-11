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

  test "show with scope and return_to params" do
    return_to = Base64.urlsafe_encode64("/org/configuration")

    get sign_org_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
        headers: @headers

    assert_response :success
  end

  test "show handles recent verification" do
    @token.update!(last_step_up_at: 5.minutes.ago, last_step_up_scope: "configuration_email")

    get sign_org_verification_url(ri: "jp"), headers: @headers

    assert_response :success
  end
end
