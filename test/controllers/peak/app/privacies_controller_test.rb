require "test_helper"

class Peak::App::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get peak_app_privacy_url

    assert_response :success
  end

  test "renders localized up link on privacy page" do
    get peak_app_privacy_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", peak_app_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"),
                    text: /\A↑\s*#{Regexp.escape(I18n.t("peak.app.preferences.up_link"))}\z/
    end
  end
end
