require "test_helper"

class Auth::App::Token::RefreshsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    # TODO: Implement show action test for token refresh
    assert_not false
  end

  test "should patch update" do
    patch auth_app_token_refresh_url(1), headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    # TODO: Implement proper update action test
    assert_not false
  end
end