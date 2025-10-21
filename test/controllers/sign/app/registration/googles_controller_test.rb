require "test_helper"
require "uri"

class Sign::App::Registration::GooglesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "redirects to google oauth provider" do
    get new_sign_app_registration_google_url, headers: { "Host" => @host }

    assert_response :redirect

    uri = URI.parse(response.redirect_url)
    assert_equal @host, uri.host
    assert_equal "/sign/google_oauth2", uri.path
  end
end
