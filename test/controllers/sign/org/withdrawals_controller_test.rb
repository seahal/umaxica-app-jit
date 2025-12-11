require "test_helper"

class Sign::Org::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["SIGN_STAFF_URL"] || "sign.org.localhost"
    @staff = staffs(:one)
  end

  def request_headers
    { "Host" => @host }
  end

  test "show action not available (route excluded)" do
    # :show action is excluded from routes with 'except: :show'
    get sign_org_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-STAFF" => @staff.id)

    assert_response :not_found
  end

  test "create sets withdrawn_at for staff" do
    skip("Org withdrawal routes not fully configured")
  end

  # Turnstile Widget Verification Tests
  test "new withdrawal page renders Turnstile widget" do
    skip("Org withdrawal :new route not available")
  end

  # Checkbox visibility tests
  test "new withdrawal page renders confirm_create_recovery_code checkbox" do
    skip("Org withdrawal :new route not available")
  end

  test "create accepts confirm_create_recovery_code parameter" do
    skip("Org withdrawal routes not fully configured")
  end
end
