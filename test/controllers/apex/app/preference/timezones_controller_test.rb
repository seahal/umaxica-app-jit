require "test_helper"

class Apex::App::Preference::TimezonesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_app_preference_timezone_url
    assert_response :success
  end

  # test "should update timezone with valid timezone" do
  #   patch apex_app_preference_timezone_url, params: { timezone: "America/New_York" }
  #   assert_response :redirect
  #   assert_equal "America/New_York", session[:timezone]
  #   assert_match(/Timezone updated/, flash[:notice])
  # end

  # test "should update timezone to UTC" do
  #   patch apex_app_preference_timezone_url, params: { timezone: "UTC" }
  #   #    assert_response :redirect
  #   assert_equal "UTC", session[:timezone]
  #   assert_match /Timezone updated/, flash[:notice]
  # end

  # test "should reject invalid timezone" do
  #   patch apex_app_preference_timezone_url, params: { timezone: "Invalid/Timezone" }
  #   assert_response :unprocessable_entity
  #   assert_equal "Invalid timezone selected", flash[:alert]
  # end

  # test "should handle missing timezone parameter" do
  #   patch apex_app_preference_timezone_url
  #   assert_response :unprocessable_entity
  #   assert_equal "Invalid timezone selected", flash[:alert]
  # end
end
