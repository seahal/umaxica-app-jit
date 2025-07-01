require "test_helper"

class Www::App::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_registration_url
    assert_response :success
  end
end
