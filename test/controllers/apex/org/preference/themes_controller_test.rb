require "test_helper"

class Apex::Org::Preference::ThemesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_org_preference_theme_url
    assert_response :success
  end

  test "should update admin theme to dark" do
    patch apex_org_preference_theme_url, params: { theme: "dark" }
    assert_response :redirect
    assert_equal "dark", session[:admin_theme]
    assert_equal I18n.t("apex.org.preferences.themes.updated", theme: "Dark Admin Theme"), flash[:notice]
  end

  test "should update admin theme to high contrast" do
    patch apex_org_preference_theme_url, params: { theme: "high_contrast" }
    assert_response :redirect
    assert_equal "high_contrast", session[:admin_theme]
    assert_equal I18n.t("apex.org.preferences.themes.updated", theme: "High Contrast Theme"), flash[:notice]
  end

  # test "should update admin theme to default" do
  #   patch apex_org_preference_theme_url, params: { theme: "admin" }
  #   assert_response :redirect
  #   assert_equal "admin", session[:admin_theme]
  #   assert_equal "Admin theme updated to Default Admin Theme", flash[:notice]
  # end

  # test "should reject invalid admin theme" do
  #   patch apex_org_preference_theme_url, params: { theme: "rainbow" }
  #   assert_response :unprocessable_content
  #   assert_equal "Invalid admin theme selected", flash[:alert]
  # end
end
