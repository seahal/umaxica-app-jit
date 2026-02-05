# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::App::Verification::EmailsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = as_user_headers(@user, host: @host)
    @token = UserToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
    UserEmail.create!(
      user: @user,
      address: "verified-#{SecureRandom.hex(4)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
      otp_private_key: "otp_private_key",
      otp_counter: "0",
    )
  end

  test "should get new" do
    get new_sign_app_verification_email_url(ri: "jp"), headers: @headers
    assert_response :success
  end

  test "create initializes a verification session" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_path(ri: "jp"))

    post sign_app_verification_emails_url(ri: "jp"),
         params: { verification: { scope: "configuration_email", return_to: return_to } },
         headers: @headers

    assert_response :redirect
    reauth_session = ReauthSession.order(created_at: :desc).first
    assert_equal "email_otp", reauth_session.method
    assert_equal @token.id, reauth_session.actor_id
  end
end
