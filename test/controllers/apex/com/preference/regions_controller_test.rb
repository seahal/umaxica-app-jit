require "test_helper"

class Apex::Com::Preference::RegionsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_com_preference_region_url
    assert_response :success
    assert_select "h1", text: I18n.t("apex.com.preferences.regions.title")
    assert_select "select[name='region']"
    assert_select "select[name='country']"
    assert_select "select[name='language']"
    assert_select "select[name='timezone']"
  end

  test "should display all form sections" do
    get edit_apex_com_preference_region_url
    assert_response :success
    assert_select "h2", text: I18n.t("apex.com.preferences.regions.region_section")
    assert_select "h2", text: I18n.t("apex.com.preferences.regions.language_section")
    assert_select "h2", text: I18n.t("apex.com.preferences.regions.timezone_section")
  end

  # test "should update language settings including Chinese" do
  #   patch apex_com_preference_region_url, params: { language: "zh" }
  #   assert_response :redirect
  #   assert_redirected_to apex_com_preference_url
  #   assert_equal "zh", session[:language]
  # end

  test "should reject unsupported language" do
    patch apex_com_preference_region_url, params: { language: "invalid" }
    assert_response :unprocessable_content
  end

  test "should reject invalid timezone" do
    patch apex_com_preference_region_url, params: { timezone: "Invalid/Timezone" }
    assert_response :unprocessable_content
  end

  # test "should update multiple settings at once" do
  #   patch apex_com_preference_region_url, params: {
  #     region: "CN",
  #     country: "CN",
  #     language: "zh",
  #     timezone: "Asia/Shanghai"
  #   }
  #   assert_response :redirect
  #   assert_redirected_to apex_com_preference_url
  #   assert_equal "CN", session[:region]
  #   assert_equal "CN", session[:country]
  #   assert_equal "zh", session[:language]
  #   assert_equal "Asia/Shanghai", session[:timezone]
  # end
end
