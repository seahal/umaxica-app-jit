# frozen_string_literal: true

require "test_helper"
require "base64"

class VerificationSessionsTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_one_time_password_statuses, :user_token_statuses, :user_token_kinds

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    host! @host

    @user = users(:one)

    @token = UserToken.create!(
      user: @user,
      user_token_status_id: UserTokenStatus::NEYO,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
      public_id: "verify_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
    )
    @token.update!(created_at: 1.hour.ago)

    @headers = {
      "X-TEST-CURRENT-USER" => @user.id.to_s,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }.freeze
  end

  test "create makes a PENDING verification session with 10-minute expiry" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_path(ri: "jp"))

    assert_difference -> { ReauthSession.count }, +1 do
      post sign_app_verification_totp_url(ri: "jp"),
           params: { verification: { scope: "configuration_email", return_to: return_to } },
           headers: @headers
    end

    assert_response :redirect
    reauth_session = ReauthSession.order(created_at: :desc).first
    assert_equal "PENDING", reauth_session.status
    assert_equal "UserToken", reauth_session.actor_type
    assert_equal @token.id, reauth_session.actor_id
    assert_in_delta 10.minutes.from_now.to_i, reauth_session.expires_at.to_i, 5
  end

  test "verify success updates token step-up and redirects to return_to" do
    private_key = "JBSWY3DPEHPK3PXP"
    UserOneTimePassword.create!(
      user: @user,
      private_key: private_key,
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      last_otp_at: Time.zone.at(0),
    )

    encoded_return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))
    reauth_session =
      ReauthSession.create!(
        actor: @token,
        scope: "configuration_email",
        return_to: encoded_return_to,
        method: "totp",
        status: "PENDING",
        expires_at: 10.minutes.from_now,
      )

    code = ROTP::TOTP.new(private_key).at(Time.current.to_i)

    post sign_app_verification_totp_url(ri: "jp"),
         params: { verification: { session_id: reauth_session.id, code: code } },
         headers: @headers

    assert_response :redirect
    assert_redirected_to sign_app_configuration_emails_url(ri: "jp")

    @token.reload
    assert_not_nil @token.last_step_up_at
    assert_equal "configuration_email", @token.last_step_up_scope

    reauth_session.reload
    assert_equal "VERIFIED", reauth_session.status
    assert_not_nil reauth_session.verified_at
  end

  test "verify failure returns 422 and increments attempt_count" do
    encoded_return_to = Base64.urlsafe_encode64(sign_app_configuration_path(ri: "jp"))
    reauth_session =
      ReauthSession.create!(
        actor: @token,
        scope: "configuration_email",
        return_to: encoded_return_to,
        method: "totp",
        status: "PENDING",
        expires_at: 10.minutes.from_now,
      )

    assert_equal 0, reauth_session.attempt_count

    post sign_app_verification_totp_url(ri: "jp"),
         params: { verification: { session_id: reauth_session.id, code: "000000" } },
         headers: @headers

    assert_response :unprocessable_content
    assert_equal 1, reauth_session.reload.attempt_count
  end

  test "expired verification session returns 410 Gone" do
    encoded_return_to = Base64.urlsafe_encode64(sign_app_configuration_path(ri: "jp"))
    reauth_session =
      ReauthSession.create!(
        actor: @token,
        scope: "configuration_email",
        return_to: encoded_return_to,
        method: "totp",
        status: "PENDING",
        expires_at: 1.minute.ago,
      )

    get new_sign_app_verification_totp_url(session_id: reauth_session.id, ri: "jp"), headers: @headers
    assert_response :gone

    post sign_app_verification_totp_url(ri: "jp"),
         params: { verification: { session_id: reauth_session.id, code: "000000" } },
         headers: @headers
    assert_response :gone
  end
end
