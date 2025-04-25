require "test_helper"

class Www::App::Registration::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get  www_app_setting_totp_index_url
    assert_response :success
  end

  test "should get new" do
    get  new_www_app_setting_totp_url
    assert_response :success
  end
end
