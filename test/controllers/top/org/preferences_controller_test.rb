require "test_helper"


class Top::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get top_org_preference_url

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should display i18n content in preferences page" do
    get top_org_preference_url

    assert_response :success
    assert_select "h1", text: I18n.t("top.org.preferences.title")
    assert_select "a", text: I18n.t("top.org.preferences.cookie_settings")
    assert_select "a", text: I18n.t("top.org.preferences.region_settings")
    assert_select "a", text: I18n.t("top.org.preferences.theme_settings")
  end
  # rubocop:enable Minitest/MultipleAssertions
end
