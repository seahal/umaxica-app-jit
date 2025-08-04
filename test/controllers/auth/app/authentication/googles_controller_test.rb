require "test_helper"

class Auth::App::Authentication::GooglesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_app_authentication_google_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    assert_response :success
  end
end
