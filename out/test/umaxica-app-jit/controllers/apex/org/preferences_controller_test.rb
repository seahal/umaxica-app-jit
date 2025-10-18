require "test_helper"

class Apex::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_org_preference_url
    assert_response :success
  end

  test "should display i18n content in preferences page" do
    get apex_org_preference_url
    assert_response :success
    assert_select "h1", text: I18n.t("apex.org.preferences.title")
    assert_select "a", text: I18n.t("apex.org.preferences.cookie_settings")
    assert_select "a", text: I18n.t("apex.org.preferences.region_settings")
    assert_select "a", text: I18n.t("apex.org.preferences.theme_settings")
  end
end
