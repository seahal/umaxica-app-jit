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

  # rubocop:disable Minitest/MultipleAssertions
  test "footer has navigation links" do
    get top_com_preference_url

    assert_select "footer" do
      assert_select "a[href=?]", "http://#{ENV['EDGE_CORPORATE_URL']}:4444/", text: I18n.t("top.com.preferences.footer.home")
      assert_select "a[href^=?]", top_com_preference_path, text: I18n.t("top.com.preferences.footer.preference")
      assert_select "a[href^=?]", top_com_privacy_path, text: I18n.t("top.com.preferences.footer.privacy")
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "shows 'うえへ' link back to preference anchor" do
    get top_com_preference_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", top_com_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"), text: /\A↑\s*#{Regexp.escape(I18n.t("top.com.preferences.up_link"))}\z/
    end
  end
end
