require "test_helper"

class Www::Org::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_org_withdrawal_url
    assert_response :success
  end

  test "should get edit" do
    get edit_www_org_withdrawal_url
    assert_response :success
  end
end
