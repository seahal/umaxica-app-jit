require "test_helper"

class Apex::App::Preference::TimezonesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_app_preference_timezone_url
    assert_response :success
  end

  test "should update timezone" do
    patch apex_app_preference_timezone_url, params: { timezone: "UTC" }
    assert_response :no_content
  end
end
