require "test_helper"

class Www::App::Registration::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should get new 2" do
    get new_www_app_registration_apple_url
    assert_response :success
  end
end
