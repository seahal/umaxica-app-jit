require "test_helper"

class Www::Net::RobotsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get www_net_robots_url(format: :txt)
    assert_response :success
  end
end
