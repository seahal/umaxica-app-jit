require "test_helper"

class Www::App::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_withdrawal_url
    assert_response :success
  end

  test "should get edit" do
    get edit_www_app_withdrawal_url
    assert_response :success
  end
end
