require "test_helper"

class Www::Org::AuthenticationControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_org_authentication_url
    assert_response :success
  end
end
