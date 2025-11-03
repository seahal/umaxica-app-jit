require "test_helper"


class Sign::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get sign_app_preference_url

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should display i18n content in preferences page" do
    get sign_app_preference_url

    assert_response :success
    assert_select "h1", text: I18n.t("sign.app.preferences.title")
    assert_select "a", text: I18n.t("sign.app.preferences.cookie_settings")
    assert_select "a", text: I18n.t("sign.app.preferences.region_settings")
    assert_select "a", text: I18n.t("sign.app.preferences.theme_settings")
  end
  # rubocop:enable Minitest/MultipleAssertions
end
