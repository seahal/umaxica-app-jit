require "test_helper"

class Sign::App::SessionsControllerTest < ActionDispatch::IntegrationTest
  def host
    ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "creates session callback response" do
    get "/sign/google/callback", headers: { "Host" => host }

    assert_response :success
    assert_equal I18n.t("common.ok"), response.body
  end
end
