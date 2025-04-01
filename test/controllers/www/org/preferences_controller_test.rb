require "test_helper"

class Www::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get www_org_preferences_show_url
    assert_response :success
  end
end
