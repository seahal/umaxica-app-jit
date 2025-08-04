require "test_helper"

class Apex::Org::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get new_apex_org_preference_email_url
    assert_response :success
  end
end
