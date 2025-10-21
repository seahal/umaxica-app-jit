require "test_helper"

class Sign::Org::AuthenticationControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_org_authentication_url
    assert_response :success
  end
end
