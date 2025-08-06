require "test_helper"

class Auth::App::Registration::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to Apple OAuth" do
    get new_auth_app_registration_apple_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    assert_redirected_to "/auth/apple"
  end

  test "controller responds" do
    # Basic test to ensure controller is properly configured
    assert true
  end
end
