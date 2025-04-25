require "test_helper"

class Docs::Com::PrivacyControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_com_privacy_index_url
    assert_select "h1", "Docs::Com::Privacies#show"
    assert_response :success
    assert_equal "text/html", @response.media_type
  end
end
