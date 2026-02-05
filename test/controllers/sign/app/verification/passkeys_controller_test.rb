# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::App::Verification::PasskeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = as_user_headers(@user, host: @host)
    @token = UserToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
  end

  test "create initializes a verification session" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_path(ri: "jp"))

    post sign_app_verification_passkey_url(ri: "jp"),
         params: { verification: { scope: "configuration_email", return_to: return_to } },
         headers: @headers

    assert_response :redirect
    reauth_session = ReauthSession.order(created_at: :desc).first
    assert_equal "passkey", reauth_session.method
    assert_equal @token.id, reauth_session.actor_id
  end

  test "should get new" do
    reauth_session = ReauthSession.create!(
      actor: @token,
      scope: "configuration_email",
      return_to: Base64.urlsafe_encode64(sign_app_configuration_path(ri: "jp")),
      method: "passkey",
      status: "PENDING",
      expires_at: 10.minutes.from_now,
    )

    get new_sign_app_verification_passkey_url(session_id: reauth_session.id, ri: "jp"), headers: @headers
    assert_response :success
  end
end
