require "test_helper"

class Peak::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  private

  def brand_name
    (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
  end

  public

  test "should get show" do
    get peak_org_preference_url

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should display i18n content in preferences page" do
    get peak_org_preference_url

    assert_response :success
    assert_select "h1", text: I18n.t("peak.org.preferences.title")
    # Verify that preference links are present (translations should exist)
    assert_select "a", minimum: 1
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should render copyright in footer" do
    get peak_org_preference_url

    assert_select "footer" do
      assert_select "small", text: /^©/
      assert_select "small", text: /#{brand_name}$/
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "footer has navigation links" do
    get peak_org_preference_url

    assert_select "footer" do
      assert_select "a[href=?]", "https://#{ENV['EDGE_STAFF_URL']}", text: I18n.t("peak.org.preferences.footer.home")
      assert_select "a[href^=?]", peak_org_preference_path, text: I18n.t("peak.org.preferences.footer.preference")
      assert_select "a[href^=?]", peak_org_privacy_path, text: I18n.t("peak.org.preferences.footer.privacy")
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "renders localized up link on preference page" do
    get peak_org_preference_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", peak_org_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"), text: /\A↑\s*#{Regexp.escape(I18n.t("peak.org.preferences.up_link"))}\z/
    end
  end
end
