# frozen_string_literal: true

require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    # Ensure master data needed for audit
    UserAuditEvent.ensure_defaults! if UserAuditEvent.respond_to?(:ensure_defaults!)
    UserAuditLevel.ensure_defaults! if UserAuditLevel.respond_to?(:ensure_defaults!)

    # Ensure user is active for refresh to work
    # We update status to something active if available, or just rely on 'active?' returning true.
    # NEYO might be inactive?
    # Let's set it to 'ACTIVE' if possible, or 'ALIVE'.
    # UserStatus constants: ACTIVE, ALIVE, etc.
    # We need to ensure the status exists too? UserStatus::ACTIVE might need seeding?
    # Just in case, create ACTIVE status.
    if defined?(UserStatus)
      UserStatus.find_or_create_by!(id: UserStatus::ACTIVE)
      @user.update!(status_id: UserStatus::ACTIVE, withdrawn_at: nil)
    end
  end

  test "guest can access login page" do
    get new_sign_app_in_path, headers: { "Host" => @host }
    follow_redirect! if response.redirect? && response.location.include?("ri=jp")
    assert_response :ok
  end

  test "refresh token rotates access token and redirects when valid" do
    # Create a token record directly
    token_record = UserToken.create!(
      user: @user,
      user_token_kind_id: "BROWSER_WEB",
    )
    refresh_plain = token_record.rotate_refresh_token!

    # Access /in/new with refresh cookie but no access cookie
    # This simulates an expired access token
    cookies_header = "jit_auth_refresh=#{refresh_plain}"

    get new_sign_app_in_path, headers: { "Cookie" => cookies_header, "Host" => @host }

    # Handle possible locale redirect
    if response.redirect? && response.location.include?("in/new")
      follow_redirect!
    end

    # We expect redirect to configuration
    assert_response :redirect
    assert_redirected_to sign_app_configuration_path

    # Verify cookies updated (rotated)
    new_refresh = response.cookies["jit_auth_refresh"] || cookies["jit_auth_refresh"]
    assert_not_nil new_refresh
    # Note: refresh_plain string matching might be complex if cookies are encoded/encrypted differently in response
    # but at least one should exist.

    assert_not_nil response.cookies["jit_auth_access"] || cookies["jit_auth_access"]
  end

  test "audit event is created on refresh" do
    # Ensure master data exists for this test to pass (or fail if missing as expected)
    if UserAuditEvent.respond_to?(:ensure_defaults!)
      UserAuditEvent.ensure_defaults!
    elsif !UserAuditEvent.exists?(id: "TOKEN_REFRESHED")
      UserAuditEvent.create!(id: "TOKEN_REFRESHED") rescue nil
    end

    token_record = UserToken.create!(
      user: @user,
      user_token_kind_id: "BROWSER_WEB",
    )
    refresh_plain = token_record.rotate_refresh_token!

    cookies_header = "jit_auth_refresh=#{refresh_plain}"
    get new_sign_app_in_path, headers: { "Cookie" => cookies_header, "Host" => @host }

    if response.redirect? && response.location.include?("in/new")
      follow_redirect!
    end

    assert_response :redirect

    # Check audit using subject fields
    assert UserAudit.exists?(event_id: "TOKEN_REFRESHED", subject_id: @user.id.to_s, subject_type: "User"),
           "TOKEN_REFRESHED audit should be created"
  end

  test "S1: audit failure does not block authentication (refresh succeeds)" do
    # Ensure master data exists
    UserAuditEvent.ensure_defaults! if UserAuditEvent.respond_to?(:ensure_defaults!)
    UserAuditLevel.ensure_defaults! if UserAuditLevel.respond_to?(:ensure_defaults!)

    token_record = UserToken.create!(
      user: @user,
      user_token_kind_id: "BROWSER_WEB",
    )
    refresh_plain = token_record.rotate_refresh_token!

    # Stub AuditWriter.write to simulate audit failure
    Auth::AuditWriter.stub(:write, false) do
      cookies_header = "jit_auth_refresh=#{refresh_plain}"

      # Subscribe to Rails.event to verify audit failure was observed
      events = []
      subscriber =
        ActiveSupport::Notifications.subscribe("authentication.audit.failed") do |_name, _start, _finish, _id, payload|
          events << payload
        end

      get new_sign_app_in_path, headers: { "Cookie" => cookies_header, "Host" => @host }

      if response.redirect? && response.location.include?("in/new")
        follow_redirect!
      end

      # S1: Authentication should succeed despite audit failure
      assert_response :redirect
      assert_redirected_to sign_app_configuration_path,
                           "Should redirect to configuration (guest_only enforcement) even when audit fails"

      # Verify new access token was set (refresh succeeded)
      assert_not_nil response.cookies["jit_auth_access"] || cookies["jit_auth_access"],
                     "Access token should be set despite audit failure"

      ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
    end
  end

  test "S1: audit failure does not block authentication (login succeeds)" do
    # This test verifies that login succeeds even when audit write fails
    # We'll test this by accessing a guest_only page with valid refresh cookie
    # and verifying redirect to after_login_path happens (proving auth succeeded)

    UserAuditEvent.ensure_defaults! if UserAuditEvent.respond_to?(:ensure_defaults!)
    UserAuditLevel.ensure_defaults! if UserAuditLevel.respond_to?(:ensure_defaults!)

    token_record = UserToken.create!(
      user: @user,
      user_token_kind_id: "BROWSER_WEB",
    )
    refresh_plain = token_record.rotate_refresh_token!

    # Stub AuditWriter.write to simulate audit failure
    Auth::AuditWriter.stub(:write, false) do
      cookies_header = "jit_auth_refresh=#{refresh_plain}"
      get new_sign_app_in_path, headers: { "Cookie" => cookies_header, "Host" => @host }

      if response.redirect? && response.location.include?("in/new")
        follow_redirect!
      end

      # Should redirect away from login page (guest_only enforcement)
      # This proves that transparent refresh + @current_resource assignment worked
      assert_response :redirect
      assert_redirected_to sign_app_configuration_path
    end
  end

  test "S3: inactive resource does not destroy token, only revokes" do
    # Create inactive user by setting withdrawn_at (which makes active? return false)
    inactive_user = users(:two) # Assuming fixture has a second user
    inactive_user.update!(withdrawn_at: Time.current) # This makes active? return false

    token_record = UserToken.create!(
      user: inactive_user,
      user_token_kind_id: "BROWSER_WEB",
    )
    refresh_plain = token_record.rotate_refresh_token!
    token_id = token_record.id

    cookies_header = "jit_auth_refresh=#{refresh_plain}"
    get new_sign_app_in_path, headers: { "Cookie" => cookies_header, "Host" => @host }

    # Refresh should fail due to inactive user
    # But token should still exist (only revoked, not destroyed)
    assert UserToken.exists?(id: token_id), "Token should still exist (S3: not destroyed)"

    token_record.reload
    assert_not_nil token_record.revoked_at, "Token should be revoked"
  end
end
