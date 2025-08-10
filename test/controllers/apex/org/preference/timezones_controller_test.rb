require "test_helper"

class Apex::Org::Preference::TimezonesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_org_preference_timezone_url
    assert_response :success
  end

  test "should update admin timezone to Tokyo" do
    patch apex_org_preference_timezone_url, params: { timezone: "Asia/Tokyo" }
    assert_response :redirect
    assert_equal "Asia/Tokyo", session[:admin_timezone]
    assert_match /Admin timezone updated/, flash[:notice]
  end

  # test "should update admin timezone to UTC" do
  #   patch apex_org_preference_timezone_url, params: { timezone: "UTC" }
  #   assert_response :redirect
  #   assert_equal "UTC", session[:admin_timezone]
  #   assert_match /Admin timezone updated to UTC/, flash[:notice]
  # end

  test "should update admin timezone to New York" do
    patch apex_org_preference_timezone_url, params: { timezone: "America/New_York" }
    assert_response :redirect
    assert_equal "America/New_York", session[:admin_timezone]
    assert_match /Admin timezone updated/, flash[:notice]
  end

  test "should reject invalid timezone" do
    patch apex_org_preference_timezone_url, params: { timezone: "Invalid/Timezone" }
    assert_response :unprocessable_entity
    assert_equal "Invalid timezone selected for admin interface", flash[:alert]
  end

  test "should handle missing timezone parameter" do
    patch apex_org_preference_timezone_url
    assert_response :unprocessable_entity
    assert_equal "Invalid timezone selected for admin interface", flash[:alert]
  end
end
