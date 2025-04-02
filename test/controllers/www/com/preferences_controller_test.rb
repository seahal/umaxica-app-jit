require "test_helper"

class Www::Com::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get www_com_preference_url
    assert_response :success
  end
end
