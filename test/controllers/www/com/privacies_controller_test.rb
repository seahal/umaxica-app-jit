require "test_helper"

class Com::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get com_privacy_url
    assert_response :success
  end
end
