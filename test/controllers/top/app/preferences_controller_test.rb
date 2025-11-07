require "test_helper"


class Top::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get top_app_preference_url

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should display i18n content in preferences page" do
    get top_app_preference_url

    assert_response :success
    assert_select "h1", text: I18n.t("top.app.preferences.title")
    assert_select "a", text: I18n.t("top.app.preferences.cookie_settings")
    assert_select "a", text: I18n.t("top.app.preferences.region_settings")
    assert_select "a", text: I18n.t("top.app.preferences.theme_settings")
  end
  # rubocop:enable Minitest/MultipleAssertions
end
