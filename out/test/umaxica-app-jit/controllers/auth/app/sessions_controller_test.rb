require "test_helper"

class Auth::App::SessionsControllerTest < ActionDispatch::IntegrationTest
  def host
    ENV["AUTH_SERVICE_URL"] || "auth.app.localhost"
  end

  test "creates session callback response" do
    get "/auth/google/callback", headers: { "Host" => host }

    assert_response :success
    assert_equal I18n.t("common.ok"), response.body
  end
end
