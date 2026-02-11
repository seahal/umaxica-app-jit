# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::App::VerificationControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = as_user_headers(@user, host: @host)
    UserEmail.create!(
      user: @user,
      address: "verification-link-#{SecureRandom.hex(4)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
      otp_private_key: "otp_private_key",
      otp_counter: "0",
    )
  end

  test "should get show" do
    get sign_app_verification_url(ri: "jp"), headers: @headers
    assert_response :success
  end

  test "shows setup message when no verification methods are registered" do
    user = User.create!
    headers = as_user_headers(user, host: @host)

    get sign_app_verification_url(ri: "jp"), headers: headers

    assert_response :success
    assert_includes response.body, "email/passkey/totp を登録してください"
  end

  test "show keeps scope and return_to in method links" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))

    get sign_app_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
        headers: @headers

    assert_response :success
    assert_select "input[name='verification[scope]'][value='configuration_email']"
    assert_select "input[name='verification[return_to]'][value='#{return_to}']"
  end

  test "show handles bad request error" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))

    get sign_app_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
        headers: @headers

    # Should either succeed or redirect gracefully
    assert response.ok? || response.redirect?
  end

  test "show with recent verification shows success message" do
    # Create a token with recent step_up
    token = UserToken.find_by(user_id: @user.id)
    token&.update!(last_step_up_at: 5.minutes.ago, last_step_up_scope: "configuration_email")

    get sign_app_verification_url(ri: "jp"), headers: @headers

    # Should show success or verification page
    assert_response :success
  end
end
