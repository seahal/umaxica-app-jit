require "test_helper"

class Apex::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_org_preference_url
    assert_response :success
  end
end
