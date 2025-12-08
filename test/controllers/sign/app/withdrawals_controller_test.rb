require "test_helper"

class Sign::App::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_app_withdrawal_url

    assert_response :success
  end

  test "should create withdrawal" do
    post sign_app_withdrawal_url

    assert_redirected_to %r{\A#{sign_app_root_url}}
  end
end
