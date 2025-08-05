require "test_helper"

class Apex::Org::Preference::RegionsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_org_preference_region_url
    assert_response :success
  end
end
