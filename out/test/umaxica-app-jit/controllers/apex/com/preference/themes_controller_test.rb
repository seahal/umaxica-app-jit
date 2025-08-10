require "test_helper"

class Apex::Com::Preference::ThemesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_com_preference_theme_url
    assert_response :success
  end

  test "should update theme" do
    patch apex_com_preference_theme_url, params: { theme: "dark" }
    assert_response :redirect
  end
end
