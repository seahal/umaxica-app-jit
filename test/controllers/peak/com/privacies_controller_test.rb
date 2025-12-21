require "test_helper"

class Peak::Com::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get peak_com_privacy_url

    assert_response :success
  end

  test "renders localized up link on privacy page" do
    get peak_com_privacy_url

    assert_select "p.mt-10" do
      assert_select "a[href=?]", peak_com_root_path(ct: "dr", lx: "en", ri: "us", tz: "jst"), text: "↑ うえへ"
    end
  end
end
