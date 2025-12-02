require "test_helper"

class Top::App::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get top_app_privacy_url

    assert_response :success
  end

  test "renders localized up link on privacy page" do
    get top_app_privacy_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", top_app_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"), text: /\A↑\s*#{Regexp.escape(I18n.t("top.app.preferences.up_link"))}\z/
    end
  end
end
