require "test_helper"

class Top::Com::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get top_com_privacy_url

    assert_response :success
  end

  test "renders localized up link on privacy page" do
    get top_com_privacy_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", top_com_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"), text: /\A\s*#{Regexp.escape(I18n.t("top.com.privacy.up_link"))}\z/
    end
  end
end
