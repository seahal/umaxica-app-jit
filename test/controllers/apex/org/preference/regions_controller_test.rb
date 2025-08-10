require "test_helper"

class Apex::Org::Preference::RegionsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_org_preference_region_url
    assert_response :success
    assert_select "h1", text: I18n.t("apex.org.preferences.regions.title")
    assert_select "select[name='region']"
    assert_select "select[name='country']"
    assert_select "select[name='language']"
    assert_select "select[name='timezone']"
  end

  test "should display all form sections" do
    get edit_apex_org_preference_region_url
    assert_response :success
    assert_select "h2", text: I18n.t("apex.org.preferences.regions.region_section")
    assert_select "h2", text: I18n.t("apex.org.preferences.regions.language_section")
    assert_select "h2", text: I18n.t("apex.org.preferences.regions.timezone_section")
  end

  test "should update region settings" do
    patch apex_org_preference_region_url, params: { region: "US", country: "US" }
    assert_response :redirect
    assert_redirected_to apex_org_preference_url
  end

  # test "should update admin language settings" do
  #   patch apex_org_preference_region_url, params: { language: "ko" }
  #   assert_response :redirect
  #   assert_redirected_to apex_org_preference_url
  #   assert_equal "ko", session[:admin_language]
  # end

  test "should reject unsupported admin language" do
    patch apex_org_preference_region_url, params: { language: "invalid" }
    assert_response :unprocessable_content
  end

  test "should update admin timezone settings" do
    patch apex_org_preference_region_url, params: { timezone: "America/New_York" }
    assert_response :redirect
    assert_redirected_to apex_org_preference_url
    assert_equal "America/New_York", session[:admin_timezone]
  end

  test "should reject invalid timezone" do
    patch apex_org_preference_region_url, params: { timezone: "Invalid/Timezone" }
    assert_response :unprocessable_content
  end

  test "should update multiple admin settings at once" do
    patch apex_org_preference_region_url, params: {
      region: "US",
      country: "US",
      language: "en",
      timezone: "America/New_York"
    }
    assert_response :redirect
    assert_redirected_to apex_org_preference_url
    assert_equal "US", session[:region]
    assert_equal "US", session[:country]
    assert_equal "en", session[:admin_language]
    assert_equal "America/New_York", session[:admin_timezone]
  end
end
