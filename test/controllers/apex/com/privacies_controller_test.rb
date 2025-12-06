require "test_helper"

class Apex::Com::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_com_privacy_url

    assert_response :success
  end

  test "renders localized up link on privacy page" do
    get apex_com_privacy_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", apex_com_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"), text: "↑ うえへ"
    end
  end
end
