require "test_helper"

class Apex::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_app_preference_url
    assert_response :success
  end

  test "should display i18n content in preferences page" do
    get apex_app_preference_url
    assert_response :success
    assert_select "h1", text: I18n.t("apex.app.preferences.title")
    assert_select "a", text: I18n.t("apex.app.preferences.cookie_settings")
    assert_select "a", text: I18n.t("apex.app.preferences.region_settings")
    assert_select "a", text: I18n.t("apex.app.preferences.email_preferences")
    assert_select "a", text: I18n.t("apex.app.preferences.theme_settings")
  end
end
