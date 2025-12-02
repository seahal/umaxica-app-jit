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
    # Verify that preference links are present (translations should exist)
    assert_select "a", minimum: 1
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should render copyright in footer" do
    get top_org_preference_url

    assert_select "footer" do
      assert_select "small", text: /^©/
      assert_select "small", text: /#{brand_name}$/
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "footer has navigation links" do
    get top_org_preference_url

    assert_select "footer" do
      assert_select "a[href=?]", "http://#{ENV['EDGE_STAFF_URL']}:4444/", text: I18n.t("top.org.preferences.footer.home")
      assert_select "a[href^=?]", top_org_preference_path, text: I18n.t("top.org.preferences.footer.preference")
      assert_select "a[href^=?]", top_org_privacy_path, text: I18n.t("top.org.preferences.footer.privacy")
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "renders localized up link on preference page" do
    get top_org_preference_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", top_org_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"), text: /\A↑\s*#{Regexp.escape(I18n.t("top.org.preferences.up_link"))}\z/
    end
  end
end
