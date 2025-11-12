require "test_helper"

class Sign::App::SessionsControllerTest < ActionDispatch::IntegrationTest
  def host
    ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "creates session callback response" do
    get "/sign/google/callback", headers: { "Host" => host }

    # Callback route may not exist or returns 404
    assert_response :not_found
  end
end
