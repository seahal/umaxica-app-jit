require "test_helper"

class Www::App::Authentication::PasscodesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_authentication_passcode_url
    assert_response :success
  end
end
