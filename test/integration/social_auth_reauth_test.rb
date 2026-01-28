# frozen_string_literal: true

require "test_helper"

# Integration tests for social auth reauth intent
#
# These tests verify:
# - MANDATORY TEST 5: Reauth intent updates users.last_reauth_at
# - Reauth requires existing linked identity
# - Reauth with wrong identity fails
class SocialAuthReauthTest < ActionDispatch::IntegrationTest
  SOCIAL_INTENT_SESSION_KEY = :social_auth_intent

  setup do
    OmniAuth.config.test_mode = true
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")

    # Create test user
    @user = User.create!(
      status_id: UserStatus::ACTIVE,
      public_id: "reauth_test_#{SecureRandom.hex(4)}",
      last_reauth_at: nil, # Explicitly nil to test update
    )

    @google_uid = "reauth_google_uid_#{SecureRandom.hex(4)}".freeze
    @apple_uid = "reauth_apple_uid_#{SecureRandom.hex(4)}".freeze
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:apple] = nil
  end

  # ============================================================================
  # MANDATORY TEST 5: Reauth callback updates users.last_reauth_at
  # ============================================================================
  test "Google reauth callback updates last_reauth_at" do
    # Setup: User has Google linked
    google_identity = UserSocialGoogle.create!(
      user: @user,
      uid: @google_uid,
      provider: "google_oauth2",
      token: "old_token",
      email: "reauth@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_google_status: user_social_google_statuses(:active),
      last_authenticated_at: 1.day.ago,
    )

    setup_google_mock_auth(uid: @google_uid, email: "reauth@example.com")

    # Verify last_reauth_at is nil before
    assert_nil @user.reload.last_reauth_at, "last_reauth_at should be nil initially"

    time_before = Time.current

    # Start reauth flow
    post sign_app_social_start_url(provider: "google_oauth2", intent: "reauth", ri: "jp"),
         headers: as_user_headers(@user, host: @host)
    assert_response :temporary_redirect
    assert_includes @response.headers["Location"], "/auth/google_oauth2"
    assert_includes @response.headers["Location"], "state="

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    # Callback with correct state and matching identity
    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp", state: valid_state),
        headers: as_user_headers(@user, host: @host)

    assert_response :redirect
    follow_redirect!

    # Success flow
    assert_predicate flash[:notice], :present?, "Should have success message"

    # CRITICAL: last_reauth_at should be updated
    @user.reload
    assert_not_nil @user.last_reauth_at, "last_reauth_at MUST be updated after reauth"
    assert_operator @user.last_reauth_at, :>=, time_before, "last_reauth_at should be recent"

    # Identity's last_authenticated_at should also be updated
    google_identity.reload
    assert_operator google_identity.last_authenticated_at, :>=, time_before
  end

  test "Apple reauth callback updates last_reauth_at" do
    UserSocialApple.create!(
      user: @user,
      uid: @apple_uid,
      provider: "apple",
      token: "old_token",
      email: "reauth_apple@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_apple_status: user_social_apple_statuses(:active),
      last_authenticated_at: 1.day.ago,
    )

    setup_apple_mock_auth(uid: @apple_uid, email: "reauth_apple@example.com")

    assert_nil @user.reload.last_reauth_at

    time_before = Time.current

    post sign_app_social_start_url(provider: "apple", intent: "reauth", ri: "jp"),
         headers: as_user_headers(@user, host: @host)
    assert_response :temporary_redirect
    assert_includes @response.headers["Location"], "/auth/apple"
    assert_includes @response.headers["Location"], "state="

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    post sign_app_auth_callback_url(provider: "apple", ri: "jp"),
         params: { state: valid_state },
         headers: as_user_headers(@user, host: @host)

    assert_response :redirect
    follow_redirect!

    @user.reload
    assert_not_nil @user.last_reauth_at, "last_reauth_at MUST be updated for Apple reauth"
    assert_operator @user.last_reauth_at, :>=, time_before
  end

  # ============================================================================
  # Reauth with mismatched identity fails
  # ============================================================================
  test "reauth with different Google uid fails" do
    @user.update!(last_reauth_at: 1.day.ago)
    # User has Google linked with one uid
    UserSocialGoogle.create!(
      user: @user,
      uid: @google_uid,
      provider: "google_oauth2",
      token: "token",
      email: "original@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_google_status: user_social_google_statuses(:active),
    )

    # Mock auth returns different uid
    different_uid = "completely_different_google_uid"
    setup_google_mock_auth(uid: different_uid, email: "different@example.com")

    original_reauth_at = @user.last_reauth_at

    post sign_app_social_start_url(provider: "google_oauth2", intent: "reauth", ri: "jp"),
         headers: as_user_headers(@user, host: @host)

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp", state: valid_state),
        headers: as_user_headers(@user, host: @host)

    assert_response :redirect

    # last_reauth_at should NOT be updated (identity mismatch)
    @user.reload
    assert_equal original_reauth_at, @user.last_reauth_at, "last_reauth_at should not change on failed reauth"
  end

  test "reauth without linked identity fails" do
    # User has no Google linked
    setup_google_mock_auth(uid: "some_unlinked_uid", email: "nolink@example.com")

    post sign_app_social_start_url(provider: "google_oauth2", intent: "reauth", ri: "jp"),
         headers: as_user_headers(@user, host: @host)

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp", state: valid_state),
        headers: as_user_headers(@user, host: @host)

    assert_response :redirect

    # Should not update reauth timestamp when not linked
    assert_nil @user.reload.last_reauth_at
  end

  test "reauth requires authentication" do
    setup_google_mock_auth(uid: "test", email: "test@example.com")

    # No auth header
    post sign_app_social_start_url(provider: "google_oauth2", intent: "reauth", ri: "jp"),
         headers: { "Host" => @host }

    # Should redirect to login page when not authenticated
    assert_response :redirect
    assert_match %r{/in}, response.location, "Reauth should require authentication"
  end

  private

    def setup_google_mock_auth(uid:, email: "test@example.com")
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: uid,
        info: { email: email, image: "https://example.com/image.jpg" },
        credentials: {
          token: "google_token_#{SecureRandom.hex(8)}",
          refresh_token: "refresh_token",
          expires_at: 1.week.from_now.to_i
        },
      )
    end

    def setup_apple_mock_auth(uid:, email: "apple@example.com")
      OmniAuth.config.mock_auth[:apple] = OmniAuth::AuthHash.new(
        provider: "apple",
        uid: uid,
        info: { email: email },
        credentials: {
          token: "apple_token_#{SecureRandom.hex(8)}",
          expires_at: 1.week.from_now.to_i
        },
      )
    end
end
