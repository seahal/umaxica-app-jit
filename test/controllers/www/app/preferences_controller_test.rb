require "test_helper"

class Www::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get www_app_preference_url
    assert_response :success
  end
end
