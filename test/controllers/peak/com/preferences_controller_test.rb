require "test_helper"

class Peak::Com::PreferencesControllerTest < ActionDispatch::IntegrationTest
  private

    def brand_name
      (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
    end

  public

  test "should get show" do
    get peak_com_preference_url

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should display i18n content in preferences page" do
    get peak_com_preference_url

    assert_response :success
    assert_select "h1", text: I18n.t("peak.com.preferences.title")
    assert_select "a", text: I18n.t("peak.com.preferences.region_settings")
    assert_select "a", text: I18n.t("peak.com.preferences.theme_settings")
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should render copyright in footer" do
    get peak_com_preference_url

    assert_select "footer" do
      assert_select "small", text: /^©/
      assert_select "small", text: /#{brand_name}$/
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "footer has navigation links" do
    get peak_com_preference_url

    assert_select "footer" do
      assert_select "a[href=?]", "https://#{ENV['EDGE_CORPORATE_URL']}",
                    text: I18n.t("peak.com.preferences.footer.home")
      assert_select "a[href^=?]", peak_com_preference_path, text: I18n.t("peak.com.preferences.footer.preference")
      assert_select "a[href^=?]", peak_com_privacy_path, text: I18n.t("peak.com.preferences.footer.privacy")
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "shows 'うえへ' link back to preference anchor" do
    get peak_com_preference_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", peak_com_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"),
                    text: /\A↑\s*#{Regexp.escape(I18n.t("peak.com.preferences.up_link"))}\z/
    end
  end
end
