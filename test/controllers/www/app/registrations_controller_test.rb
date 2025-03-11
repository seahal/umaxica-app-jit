require "test_helper"

class Www::App::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get www_app_registrations_new_url
    assert_response :success
  end
end
