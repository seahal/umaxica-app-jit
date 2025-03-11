require "test_helper"

class Org::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get org_privacy_url
    assert_response :success
  end
end
