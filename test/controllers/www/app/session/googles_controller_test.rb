require "test_helper"

class Net::Session::GooglesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_net_session_google_url
    assert_response :success
  end
end
