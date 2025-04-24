require "test_helper"

class Www::App::Session::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_authentication_email_url
    assert_response :success
  end
end
