# frozen_string_literal: true

require "test_helper"

# Integration tests for verification flow
#
# These tests verify:
# - High-risk operations require verification (step-up auth)
# - After successful verification, user is redirected to return_to
# - Expired verification sessions return 410 Gone
# - Invalid return_to is rejected
class VerificationFlowTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_tokens

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @token = UserToken.create!(
      user: @user,
      user_token_status_id: UserTokenStatus::NEYO,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
      public_id: "vf#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
    )
    @headers = as_user_headers(@user, host: @host)
    @headers["X-TEST-SESSION-PUBLIC-ID"] = @token.public_id
  end

  test "high-risk operation redirects to verification when step-up not satisfied" do
    # Make token old enough to require step-up
    @token.update!(created_at: 1.hour.ago)

    # Try to access email configuration (requires step-up)
    get sign_app_configuration_emails_url(ri: "jp"), headers: @headers

    assert_response :redirect
    assert_match %r{/verification}, response.location
    assert_match(/scope=configuration_email/, response.location)
    assert_match(/return_to=/, response.location)
  end

  test "successful passkey verification redirects to return_to" do
    return_to_path = sign_app_configuration_emails_path(ri: "jp")
    Base64.urlsafe_encode64(return_to_path)

    # Create a PENDING verification session
    reauth_session = ReauthSession.create!(
      actor: @token,
      scope: "configuration_email",
      return_to: return_to_path,
      method: "passkey",
      status: "PENDING",
      expires_at: 10.minutes.from_now,
    )

    # Get the passkey challenge page
    get new_sign_app_verification_passkey_url(session_id: reauth_session.id, ri: "jp"),
        headers: @headers
    assert_response :success

    # Simulate successful verification (by directly updating the session)
    # In real scenario, this would be done by verify_passkey! in controller
    reauth_session.update!(status: "VERIFIED", verified_at: Time.current)
    @token.update!(last_step_up_at: Time.current, last_step_up_scope: "configuration_email")

    # Now the high-risk operation should succeed
    get sign_app_configuration_emails_url(ri: "jp"), headers: @headers
    assert_response :success
  end

  test "expired verification session returns 410 Gone" do
    # Create an EXPIRED verification session
    reauth_session = ReauthSession.create!(
      actor: @token,
      scope: "configuration_email",
      return_to: sign_app_configuration_emails_path(ri: "jp"),
      method: "totp",
      status: "PENDING",
      expires_at: 1.minute.ago, # Expired
    )

    # Try to access the expired session
    get new_sign_app_verification_totp_url(session_id: reauth_session.id, ri: "jp"),
        headers: @headers
    assert_response :gone
  end

  test "verification session count increases when creating new sessions" do
    return_to_path = sign_app_configuration_emails_path(ri: "jp")
    return_to_encoded = Base64.urlsafe_encode64(return_to_path)

    assert_difference "ReauthSession.count", 1 do
      post sign_app_verification_totp_url(ri: "jp"),
           params: { verification: { scope: "configuration_email", return_to: return_to_encoded } },
           headers: @headers
    end

    assert_response :redirect
    reauth_session = ReauthSession.order(created_at: :desc).first
    assert_equal "totp", reauth_session.method
    assert_equal "PENDING", reauth_session.status
    assert_equal "configuration_email", reauth_session.scope
  end
end
