require "test_helper"

class Sign::App::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_app_withdrawal_url
    assert_response :success
  end

  test "should get edit" do
    get edit_sign_app_withdrawal_url
    assert_response :success
  end
end
