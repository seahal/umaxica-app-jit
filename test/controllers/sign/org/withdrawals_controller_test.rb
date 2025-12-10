require "test_helper"

class Sign::Org::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["SIGN_STAFF_URL"] || "sign.org.localhost"
    @staff = staffs(:one)
  end

  def request_headers
    { "Host" => @host }
  end

  test "GET show renders for active staff" do
    get sign_org_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-STAFF" => @staff.id)

    assert_response :success
    assert_select "h1", minimum: 1
  end

  test "GET show returns 404 for withdrawn staff" do
    @staff.update!(withdrawn_at: 1.day.ago)

    get sign_org_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-STAFF" => @staff.id)

    assert_response :not_found
  end

  test "create sets withdrawn_at for staff" do
    post sign_org_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-STAFF" => @staff.id)

    assert_redirected_to sign_org_root_url(host: @host)
    assert_not_nil @staff.reload.withdrawn_at
  end

  # Turnstile Widget Verification Tests
  test "new withdrawal page renders Turnstile widget" do
    get new_sign_org_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-STAFF" => @staff.id)

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end
end
