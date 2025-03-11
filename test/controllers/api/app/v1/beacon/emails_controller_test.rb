require "test_helper"

class Net::V1::Beacon::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get net_v1_beacon_email_url 1000
    assert_response :success
  end
end
