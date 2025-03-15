require "test_helper"

class Net::Session::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_session_apple_url
    assert_response :success
  end
end
