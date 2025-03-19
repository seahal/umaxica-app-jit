require "test_helper"

class Api::App::RobotsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_app_robots_url format: :txt
    assert_response :success
  end
end
