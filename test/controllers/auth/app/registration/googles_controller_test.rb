require "test_helper"
require "uri"

class Auth::App::Registration::GooglesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["AUTH_SERVICE_URL"] || "auth.app.localhost"
  end

  test "redirects to google oauth provider" do
    get new_auth_app_registration_google_url, headers: { "Host" => @host }

    assert_response :redirect

    uri = URI.parse(response.redirect_url)
    assert_equal @host, uri.host
    assert_equal "/auth/google_oauth2", uri.path
  end
end
