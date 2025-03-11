require "test_helper"

class Net::Session::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_net_session_password_url
    assert_response :success
  end
end
