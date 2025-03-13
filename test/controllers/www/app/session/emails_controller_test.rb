require "test_helper"

class Net::Session::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_net_session_email_url
    assert_response :success
  end
end
