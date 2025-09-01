require "test_helper"

class Auth::App::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_app_withdrawal_url
    assert_response :success
  end

  test "should get edit" do
    get edit_auth_app_withdrawal_url
    assert_response :success
  end
end
