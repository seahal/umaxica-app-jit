require "test_helper"


class Root::Com::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get root_com_preference_url

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should display i18n content in preferences page" do
    get root_com_preference_url

    assert_response :success
    assert_select "h1", text: I18n.t("root.com.preferences.title")
    assert_select "a", text: I18n.t("root.com.preferences.cookie_settings")
    assert_select "a", text: I18n.t("root.com.preferences.region_settings")
    assert_select "a", text: I18n.t("root.com.preferences.theme_settings")
  end
  # rubocop:enable Minitest/MultipleAssertions
end
