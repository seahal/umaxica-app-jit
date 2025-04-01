require "test_helper"

class Www::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get new_www_app_preferences_url
    assert_response :success
  end
end
