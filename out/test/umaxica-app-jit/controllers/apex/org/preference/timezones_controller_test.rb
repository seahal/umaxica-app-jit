require "test_helper"

class Apex::Org::Preference::TimezonesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_org_preference_timezone_url
    assert_response :success
  end

  test "should update timezone" do
    patch apex_org_preference_timezone_url, params: { timezone: "UTC" }
    assert_response :redirect
  end
end
