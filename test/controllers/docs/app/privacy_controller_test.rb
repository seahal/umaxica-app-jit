require "test_helper"

class Docs::App::PrivacyControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docs_app_privacy_url
    assert_select "h1", "Docs::App::Privacies#index"
    assert_select "p", "Find me in app/views/docs/app/privacies/index.html.erb"
    assert_response :success
    assert_equal "text/html", @response.media_type
  end
end
