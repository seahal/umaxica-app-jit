require "test_helper"

class Net::Session::PasskeysControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_net_session_passkey_url
    assert_response :success
  end
end
