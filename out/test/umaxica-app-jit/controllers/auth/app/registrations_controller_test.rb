require "test_helper"

class Auth::App::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_app_registration_url(format: :html), headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    assert_response :success
  end
end
