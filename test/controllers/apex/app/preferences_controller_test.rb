require "test_helper"

class Apex::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  private

  def brand_name
    (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
  end

  public

  test "should get show" do
    get apex_app_preference_url

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should display i18n content in preferences page" do
    get apex_app_preference_url

    assert_response :success
    assert_select "h1", text: I18n.t("apex.app.preferences.title")
    assert_select "li", text: I18n.t("apex.app.preferences.region_settings")
    assert_select "li", text: I18n.t("apex.app.preferences.theme_settings")
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should render copyright in footer" do
    get apex_app_preference_url

    assert_select "footer" do
      assert_select "small", text: /^©/
      assert_select "small", text: /#{brand_name}$/
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "footer has navigation links" do
    get apex_app_preference_url

    assert_select "footer" do
      assert_select "a[href=?]", "https://#{ENV['EDGE_SERVICE_URL']}", text: I18n.t("apex.app.preferences.footer.home")
      assert_select "a[href^=?]", apex_app_preference_path, text: I18n.t("apex.app.preferences.footer.preference")
      assert_select "a[href^=?]", apex_app_privacy_path, text: I18n.t("apex.app.preferences.footer.privacy")
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "renders localized up link on preferences page" do
    get apex_app_preference_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", apex_app_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"), text: /\A↑\s*#{Regexp.escape(I18n.t("apex.app.preferences.up_link"))}\z/
    end
  end
end
