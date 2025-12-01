require "test_helper"


class Top::Com::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get top_com_preference_url

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should display i18n content in preferences page" do
    get top_com_preference_url

    assert_response :success
    assert_select "h1", text: I18n.t("top.com.preferences.title")
    assert_select "a", text: I18n.t("top.com.preferences.cookie_settings")
    assert_select "a", text: I18n.t("top.com.preferences.region_settings")
    assert_select "a", text: I18n.t("top.com.preferences.theme_settings")
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should render copyright in footer" do
    get top_com_preference_url

    assert_select "footer" do
      assert_select "small", text: /^©/
      assert_select "small", text: /#{brand_name}$/
    end
  end
  # rubocop:enable Minitest/MultipleAssertions
end
