# frozen_string_literal: true

require "test_helper"

class Apex::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  private

  def brand_name
    (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
  end

  public

  test "should get show" do
    get apex_org_preference_url

    assert_response :success
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should display i18n content in preferences page" do
    get apex_org_preference_url

    assert_response :success
    assert_select "h1", text: I18n.t("apex.org.preferences.title")
    # Verify that preference links are present (translations should exist)
    assert_select "a[href*=?]", edit_apex_org_preference_cookie_path,
                  text: I18n.t("apex.org.preferences.cookie_settings")
    assert_select "a", minimum: 1
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should render copyright in footer" do
    get apex_org_preference_url

    assert_select "footer" do
      assert_select "small", text: /^©/
      assert_select "small", text: /#{brand_name}$/
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "footer has navigation links" do
    get apex_org_preference_url

    assert_select "footer" do
      assert_select "a[href=?]", "http://org.localhost:3000/", text: I18n.t("apex.org.preferences.footer.home")
      assert_select "a[href*=?]", apex_org_preference_path, text: I18n.t("apex.org.preferences.footer.preference")
      assert_select "a[href*=?]", apex_org_configuration_path, text: I18n.t("apex.org.configurations.title")
      assert_select "a", count: 3
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "renders localized up link on preference page" do
    get apex_org_preference_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", apex_org_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"),
                    text: /\A↑\s*#{Regexp.escape(I18n.t("apex.org.preferences.up_link"))}\z/
    end
  end

  test "header nav shows sign up and log in links when not logged in" do
    get apex_org_preference_url

    assert_select "header nav" do
      assert_select "a[href=?]", new_sign_org_up_url(host: ENV["SIGN_STAFF_URL"]),
                    text: I18n.t("sign.org.layout.nav.sign_up")
      assert_select "a[href=?]", new_sign_org_in_url(host: ENV["SIGN_STAFF_URL"]),
                    text: I18n.t("sign.org.layout.nav.log_in")
    end
  end
end
