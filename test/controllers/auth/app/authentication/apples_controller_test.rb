require "test_helper"

class Auth::App::Authentication::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to apple auth" do
    get new_auth_app_authentication_apple_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    assert_response :redirect
    assert_redirected_to "/auth/apple"
  end

  test "create should redirect to apple auth" do
    post auth_app_authentication_apple_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    assert_response :redirect
    assert_redirected_to "/auth/apple"
  end
end
