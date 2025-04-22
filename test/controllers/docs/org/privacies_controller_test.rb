require "test_helper"

class Docs::Org::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_org_privacies_show_url
    assert_response :success
  end
end
