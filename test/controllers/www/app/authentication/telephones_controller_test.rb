require "test_helper"

class Www::App::Authentication::TelephonesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_authentication_telephone_url
    assert_response :success
  end
end
