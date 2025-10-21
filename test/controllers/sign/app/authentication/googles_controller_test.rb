require "test_helper"

class Sign::App::Authentication::GooglesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_app_authentication_google_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"] }
    assert_response :redirect
    assert_redirected_to "/sign/google_oauth2"
  end
end
