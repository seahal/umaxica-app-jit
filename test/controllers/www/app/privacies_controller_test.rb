require "test_helper"

class Net::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get www_app_privacy_url
    assert_response :success
  end
end
