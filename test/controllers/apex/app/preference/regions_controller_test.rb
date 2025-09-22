require "test_helper"

class Apex::App::Preference::RegionsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_app_preference_region_url
    assert_response :success
    assert_select "h1", text: I18n.t("apex.app.preferences.regions.title")
    assert_select "select[name='region']"
    assert_select "select[name='country']"
    assert_select "select[name='language']"
    assert_select "select[name='timezone']"
  end

  test "should display all form sections" do
    get edit_apex_app_preference_region_url
    assert_response :success
    assert_select "h2", text: I18n.t("apex.app.preferences.regions.region_section")
    assert_select "h2", text: I18n.t("apex.app.preferences.regions.language_section")
    assert_select "h2", text: I18n.t("apex.app.preferences.regions.timezone_section")
  end

  # test "should update region settings" do
  #   patch apex_app_preference_region_url, params: { region: "JP", country: "JP" }
  #   assert_response :redirect
  #   assert_redirected_to apex_app_preference_url
  # end

  # test "should update language settings" do
  #   patch apex_app_preference_region_url, params: { language: "ja" }
  #   assert_response :redirect
  #   assert_redirected_to apex_app_preference_url
  #   assert_equal "ja", session[:language]
  # end

  test "should reject unsupported language" do
    patch apex_app_preference_region_url, params: { language: "invalid" }
    assert_response :unprocessable_content
  end

  # test "should update timezone settings" do
  #   patch apex_app_preference_region_url, params: { timezone: "Asia/Tokyo" }
  #   assert_response :redirect
  #   assert_redirected_to apex_app_preference_url
  #   assert_equal "Asia/Tokyo", session[:timezone]
  # end

  test "should reject invalid timezone" do
    patch apex_app_preference_region_url, params: { timezone: "Invalid/Timezone" }
    assert_response :unprocessable_content
  end

  test "should update multiple settings at once" do
    patch apex_app_preference_region_url, params: {
      region: "JP",
      country: "JP",
      language: "ja",
      timezone: "Asia/Tokyo"
    }
    assert_response :redirect
    assert_redirected_to apex_app_preference_url
    assert_equal "JP", session[:region]
    assert_equal "JP", session[:country]
    assert_equal "ja", session[:language]
    assert_equal "Asia/Tokyo", session[:timezone]
  end
end
