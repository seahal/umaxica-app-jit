require "test_helper"

class Www::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get www_com_preference_url
    assert_response :success
  end
end
