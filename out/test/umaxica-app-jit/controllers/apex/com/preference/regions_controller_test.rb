require "test_helper"

class Apex::Com::Preference::RegionsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_com_preference_region_url
    assert_response :success
  end
end
