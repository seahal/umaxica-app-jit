require "test_helper"

class Auth::Org::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_org_withdrawal_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }
    assert_response :success
  end

  test "should get edit" do
    # TODO: Implement edit action test
    assert_not false
  end

  test "should post create" do
    # TODO: Implement create action test
    assert_not false
  end

  test "should patch update" do
    # TODO: Implement update action test
    assert_not false
  end
end
