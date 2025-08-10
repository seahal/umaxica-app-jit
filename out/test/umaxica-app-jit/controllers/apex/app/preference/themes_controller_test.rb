require "test_helper"

class Apex::App::Preference::ThemesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_app_preference_theme_url
    assert_response :success
  end

  test "should update theme" do
    patch apex_app_preference_theme_url, params: { theme: "dark" }
    assert_response :no_content
  end
end
