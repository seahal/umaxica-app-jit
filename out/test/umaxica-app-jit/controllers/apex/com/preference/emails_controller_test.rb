require "test_helper"

class Apex::Com::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_com_preference_email_url
    assert_response :success
  end

  test "should update email preferences" do
    patch apex_com_preference_email_url, params: { email_notifications: true }
    assert_response :redirect
  end
end
