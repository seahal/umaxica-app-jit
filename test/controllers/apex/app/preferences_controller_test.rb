require "test_helper"

class Apex::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_app_preference_url
    assert_response :success
  end
end
