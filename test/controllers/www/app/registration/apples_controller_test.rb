require "test_helper"

class Net::Registration::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_net_registration_apple_url
    assert_response :success
  end
end
