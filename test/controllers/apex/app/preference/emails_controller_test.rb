require "test_helper"

class Apex::App::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_app_preference_email_url
    assert_response :success
  end

  test "should update email preferences with valid params" do
    patch apex_app_preference_email_url, params: { 
      notifications: true, 
      marketing: false,
      security_alerts: true 
    }
    assert_response :redirect
    assert_equal "Email preferences updated successfully", flash[:notice]
  end

  test "should handle update with no params" do
    patch apex_app_preference_email_url
    assert_response :unprocessable_entity
    assert_equal "Invalid email preferences", flash[:alert]
  end
end
