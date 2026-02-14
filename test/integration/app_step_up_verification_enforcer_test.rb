# frozen_string_literal: true

require "test_helper"
require "base64"

class AppStepUpVerificationEnforcerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_one_time_password_statuses, :user_activity_events, :user_activity_levels

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = as_user_headers(@user, host: @host)
    @token = UserToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
  end

  test "GET protected endpoint redirects to verification when step-up is missing" do
    get sign_app_configuration_emails_url(ri: "jp"), headers: @headers

    assert_response :redirect
    assert_includes response.location, "/verification"
  end

  test "POST protected endpoint returns 401 plain when step-up is missing" do
    post sign_app_configuration_withdrawal_url(ri: "jp"), headers: @headers

    assert_response :unauthorized
    assert_equal "Re-authentication required", response.body
  end

  test "successful verification enables protected POST and records audit" do
    private_key = "JBSWY3DPEHPK3PXP"
    UserOneTimePassword.create!(
      user: @user,
      private_key: private_key,
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      last_otp_at: Time.zone.at(0),
    )

    return_to = Base64.urlsafe_encode64(sign_app_configuration_withdrawal_path(ri: "jp"))

    get sign_app_verification_url(scope: "withdrawal", return_to: return_to, ri: "jp"), headers: @headers
    assert_response :success

    code = ROTP::TOTP.new(private_key).at(Time.current.to_i)
    post sign_app_verification_totp_url(ri: "jp"),
         params: { verification: { code: code } },
         headers: @headers

    assert_response :redirect
    assert_redirected_to sign_app_configuration_withdrawal_url(ri: "jp")
    assert response_has_cookie?(UserVerification.cookie_name)

    assert UserVerification.active.exists?(user_token_id: @token.id)
    assert UserActivity.exists?(
      actor_type: "User",
      actor_id: @user.id,
      event_id: UserActivityEvent::STEP_UP_VERIFIED,
      subject_type: "User",
      subject_id: @user.id,
    )

    post sign_app_configuration_withdrawal_url(ri: "jp"), headers: @headers

    assert_not_equal 401, response.status
  end
end
