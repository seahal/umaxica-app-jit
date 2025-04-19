require "test_helper"

class Www::App::SettingControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get www_app_setting_url
    assert_response :success
  end
end
