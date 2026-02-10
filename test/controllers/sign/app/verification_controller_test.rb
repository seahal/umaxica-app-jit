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
end
