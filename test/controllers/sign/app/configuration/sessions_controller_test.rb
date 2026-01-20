# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @headers = { "Host" => @host, "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "index returns active sessions" do
    get sign_app_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :success
    assert response.parsed_body.key?("sessions")
  end

  test "destroy revokes session and returns see_other" do
    # Create a user token to revoke
    user_token = UserToken.create!(
      user_id: @user.id,
      public_id: "test_session_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
      user_token_kind_id: "BROWSER_WEB",
    )

    delete sign_app_configuration_session_url(user_token.public_id, ri: "jp"), headers: @headers
    assert_response :see_other

    user_token.reload
    assert_not_nil user_token.revoked_at
  end

  test "requires authentication" do
    get sign_app_configuration_sessions_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :redirect
  end
end
