# frozen_string_literal: true

require "test_helper"
require "base64"

class OrgReauthTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_one_time_password_statuses

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    host! @host

    @staff = staffs(:one)

    @token = StaffToken.create!(
      staff: @staff,
      staff_token_status_id: StaffTokenStatus::NEYO,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      public_id: "org_reauth_#{SecureRandom.hex(5)}",
      refresh_expires_at: 1.day.from_now,
    )
    @token.update!(created_at: 1.hour.ago)

    @headers = {
      "X-TEST-CURRENT-STAFF" => @staff.id.to_s,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }.freeze
  end

  test "create makes a PENDING reauth_session with 10-minute expiry" do
    return_to = Base64.urlsafe_encode64(sign_org_configuration_path(ri: "jp"))

    assert_difference -> { ReauthSession.count }, +1 do
      post sign_org_reauth_index_url(ri: "jp"),
           params: { reauth_session: { scope: "configuration_email", return_to: return_to, method: "totp" } },
           headers: @headers
    end

    assert_response :redirect
    reauth_session = ReauthSession.order(created_at: :desc).first
    assert_equal "PENDING", reauth_session.status
    assert_equal "StaffToken", reauth_session.actor_type
    assert_equal @token.id, reauth_session.actor_id
    assert_in_delta 10.minutes.from_now.to_i, reauth_session.expires_at.to_i, 5
  end

  test "update verify success updates token step-up and redirects to return_to" do
    private_key = "JBSWY3DPEHPK3PXP"
    StaffOneTimePassword.create!(
      staff: @staff,
      private_key: private_key,
      staff_one_time_password_status_id: StaffOneTimePasswordStatus::ACTIVE,
    )

    encoded_return_to = Base64.urlsafe_encode64(sign_org_configuration_path(ri: "jp"))
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

    patch sign_org_reauth_url(reauth_session, ri: "jp"),
          params: { reauth_session: { code: code } },
          headers: @headers

    assert_response :redirect
    assert_redirected_to sign_org_configuration_url(ri: "jp")

    @token.reload
    assert_not_nil @token.last_step_up_at
    assert_equal "configuration_email", @token.last_step_up_scope

    reauth_session.reload
    assert_equal "VERIFIED", reauth_session.status
    assert_not_nil reauth_session.verified_at
  end

  test "update verify failure returns 422 and increments attempt_count" do
    encoded_return_to = Base64.urlsafe_encode64(sign_org_configuration_path(ri: "jp"))
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

    patch sign_org_reauth_url(reauth_session, ri: "jp"),
          params: { reauth_session: { code: "000000" } },
          headers: @headers

    assert_response :unprocessable_content
    assert_equal 1, reauth_session.reload.attempt_count
  end

  test "expired reauth_session edit and update return 410 Gone" do
    encoded_return_to = Base64.urlsafe_encode64(sign_org_configuration_path(ri: "jp"))
    reauth_session =
      ReauthSession.create!(
        actor: @token,
        scope: "configuration_email",
        return_to: encoded_return_to,
        method: "totp",
        status: "PENDING",
        expires_at: 1.minute.ago,
      )

    get edit_sign_org_reauth_url(reauth_session, ri: "jp"), headers: @headers
    assert_response :gone

    patch sign_org_reauth_url(reauth_session, ri: "jp"),
          params: { reauth_session: { code: "000000" } },
          headers: @headers
    assert_response :gone
  end

  test "destroy cancels a PENDING reauth_session" do
    encoded_return_to = Base64.urlsafe_encode64(sign_org_configuration_path(ri: "jp"))
    reauth_session =
      ReauthSession.create!(
        actor: @token,
        scope: "configuration_email",
        return_to: encoded_return_to,
        method: "totp",
        status: "PENDING",
        expires_at: 10.minutes.from_now,
      )

    delete sign_org_reauth_url(reauth_session, ri: "jp"), headers: @headers
    assert_response :see_other

    assert_equal "CANCELLED", reauth_session.reload.status
  end
end
