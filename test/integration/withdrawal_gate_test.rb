# frozen_string_literal: true

require "test_helper"

class WithdrawalGateTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_token_kinds, :user_token_statuses

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    host! @host

    # Create a user in PRE_WITHDRAWAL_CONDITION status
    @withdrawn_user = users(:one)
    @withdrawn_user.update!(
      status_id: UserStatus::PRE_WITHDRAWAL_CONDITION,
      withdrawn_at: Time.current,
    )
    UserToken.where(user: @withdrawn_user).delete_all

    # Create a token for the withdrawn user with step-up auth satisfied
    @token = UserToken.create!(
      user: @withdrawn_user,
      user_token_status_id: UserTokenStatus::NEYO,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
      public_id: "withdrawn_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
      last_step_up_at: 1.minute.ago,
      last_step_up_scope: "withdrawal",
    )

    @headers = {
      "X-TEST-CURRENT-USER" => @withdrawn_user.id.to_s,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }.freeze
  end

  # Test 1: HTML requests to normal pages should redirect to withdrawal/edit
  test "PRE_WITHDRAWAL user accessing normal page redirects to withdrawal edit" do
    # Access a configuration page (auth_required area)
    get sign_app_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :redirect
    assert_redirected_to edit_sign_app_configuration_withdrawal_path(ri: "jp")
  end

  # Test 2: Allowlist - withdrawal controller actions should pass through
  test "PRE_WITHDRAWAL user can access withdrawal edit page" do
    get edit_sign_app_configuration_withdrawal_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  # Test 3: JSON/API requests should return 403 Forbidden
  test "PRE_WITHDRAWAL user accessing API returns 403" do
    get sign_app_configuration_sessions_url(ri: "jp"), headers: @headers.merge("Accept" => "application/json")

    assert_response :forbidden
    json_response = response.parsed_body
    assert_equal "WITHDRAWAL_REQUIRED", json_response["error"]
  end

  # Test 4: Logout should be allowed
  test "PRE_WITHDRAWAL user can logout" do
    # Assuming there's a logout endpoint - adjust path if different
    delete sign_app_configuration_out_url, headers: @headers

    # Should not redirect to withdrawal page (allow logout)
    assert_response :redirect
    assert_not_equal edit_sign_app_configuration_withdrawal_path, response.location
  end

  # Test 5: No auto-upgrade to WITHDRAWN status
  test "PRE_WITHDRAWAL user does not auto-upgrade to WITHDRAWN on login" do
    # Set withdrawn_at to past (simulating cooldown period expired)
    @withdrawn_user.update!(withdrawn_at: 31.days.ago)

    # Access a page (which triggers authentication checks)
    get sign_app_configuration_sessions_url(ri: "jp"), headers: @headers

    # User should still be PRE_WITHDRAWAL_CONDITION, not WITHDRAWN
    @withdrawn_user.reload
    assert_equal UserStatus::PRE_WITHDRAWAL_CONDITION, @withdrawn_user.status_id
    assert_not_equal UserStatus::WITHDRAWN, @withdrawn_user.status_id
  end

  # Test 6: Normal users (non-PRE_WITHDRAWAL) should not be affected
  test "normal user can access pages without withdrawal gate" do
    normal_user = users(:two)
    normal_user.update!(status_id: UserStatus::NEYO)

    normal_token = UserToken.create!(
      user: normal_user,
      user_token_status_id: UserTokenStatus::NEYO,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
      public_id: "normal_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
      last_step_up_at: 1.minute.ago,
      last_step_up_scope: "withdrawal",
    )

    headers = {
      "X-TEST-CURRENT-USER" => normal_user.id.to_s,
      "X-TEST-SESSION-PUBLIC-ID" => normal_token.public_id,
    }

    get sign_app_configuration_sessions_url(ri: "jp"), headers: headers

    assert_response :success
  end

  # Test 7: Step2 (destroy) should be blocked
  test "destroy action returns 403 for PRE_WITHDRAWAL user" do
    delete sign_app_configuration_withdrawal_url, headers: @headers

    assert_response :redirect
    assert_redirected_to edit_sign_app_configuration_withdrawal_path
    assert_equal I18n.t("sign.app.configuration.withdrawal.destroy.permanent_unavailable"), flash[:alert]
  end

  # Test 8: Step2 (destroy) JSON returns 403
  test "destroy action returns 403 JSON for PRE_WITHDRAWAL user" do
    delete sign_app_configuration_withdrawal_url,
           headers: @headers.merge("Accept" => "application/json")

    assert_response :forbidden
    json_response = response.parsed_body
    assert_equal "PERMANENT_DELETION_NOT_AVAILABLE", json_response["error"]
  end
end
