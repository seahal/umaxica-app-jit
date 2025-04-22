require "test_helper"

class Docs::Com::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_com_privacy_url
    assert_response :success
  end
end
