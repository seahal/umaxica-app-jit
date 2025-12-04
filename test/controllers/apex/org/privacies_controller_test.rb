require "test_helper"

class Apex::Org::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_org_privacy_url

    assert_response :success
  end

  test "renders localized up link on privacy page" do
    get apex_org_privacy_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", apex_org_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"), text: /\A↑\s*#{Regexp.escape(I18n.t("apex.org.preferences.up_link"))}\z/
    end
  end
end
