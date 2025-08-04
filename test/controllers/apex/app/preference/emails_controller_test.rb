require "test_helper"

class Apex::App::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get new_apex_app_preference_email_url
    assert_response :success
  end
end
