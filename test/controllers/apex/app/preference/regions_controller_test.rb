require "test_helper"

class Apex::App::Preference::RegionsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_app_preference_region_url
    assert_response :success
  end
end
