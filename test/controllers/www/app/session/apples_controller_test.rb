require "test_helper"

class Net::Session::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_net_session_apple_url
    assert_response :success
  end
end
