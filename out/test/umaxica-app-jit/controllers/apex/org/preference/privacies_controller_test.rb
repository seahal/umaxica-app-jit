require "test_helper"

class Apex::Org::Preference::PrivaciesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_org_preference_privacy_url
    assert_response :success
  end

  test "should update privacy settings" do
    patch apex_org_preference_privacy_url, params: { privacy_level: "strict" }
    assert_response :redirect
  end
end
