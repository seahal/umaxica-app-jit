require "test_helper"

class Apex::Com::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_com_preference_url
    assert_response :success
  end
end
