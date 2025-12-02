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
    assert_select "li", text: I18n.t("top.app.preferences.region_settings")
    assert_select "li", text: I18n.t("top.app.preferences.theme_settings")
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should render copyright in footer" do
    get top_app_preference_url

    assert_select "footer" do
      assert_select "small", text: /^©/
      assert_select "small", text: /#{brand_name}$/
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "footer has navigation links" do
    get top_app_preference_url

    assert_select "footer" do
      assert_select "a", text: I18n.t("top.app.preferences.footer.home")
      assert_select "a", text: I18n.t("top.app.preferences.footer.preference"), href: top_app_preference_path
      assert_select "a", text: I18n.t("top.app.preferences.footer.privacy"), href: top_app_privacy_path
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "renders localized up link on preferences page" do
    get top_app_preference_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", top_app_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"), text: /\A↑\s*#{Regexp.escape(I18n.t("top.app.preferences.up_link"))}\z/
    end
  end
end
