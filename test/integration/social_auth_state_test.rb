# frozen_string_literal: true

require "test_helper"

# Integration tests for social auth state validation (CSRF protection)
#
# These tests verify that:
# 1. State parameter is validated for both Google and Apple callbacks
# 2. State mismatch returns redirect with error (401 via SocialAuth::UnauthorizedError)
# 3. Missing state returns redirect with error
# 4. Expired state returns redirect with error
#
# Both Google and Apple MUST validate state. If either is exempted,
# the corresponding tests will FAIL.
#
# Routes used:
#   GET  /social/start?provider=...&intent=...  -> prepares intent, redirects to OmniAuth
#   GET  /auth/:provider/callback?state=...     -> Google callback
#   POST /auth/:provider/callback (state in body) -> Apple callback
#   GET  /auth/failure                          -> OmniAuth failure
class SocialAuthStateTest < ActionDispatch::IntegrationTest
  SOCIAL_INTENT_SESSION_KEY = :social_auth_intent

  setup do
    OmniAuth.config.test_mode = true
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:apple] = nil
  end

  # ============================================================================
  # MANDATORY TEST 1: Google state mismatch -> 401
  # ============================================================================
  test "Google callback with state mismatch returns error and clears session" do
    setup_google_mock_auth(uid: "google_mismatch_test")

    # Start OAuth flow to establish session with valid state
    get sign_app_social_start_url(provider: "google_oauth2", intent: "login", ri: "jp"),
        headers: { "Host" => @host }
    assert_response :redirect

    # Verify session has state stored
    assert_predicate session[SOCIAL_INTENT_SESSION_KEY], :present?, "Intent should be in session after start"
    original_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]
    assert_predicate original_state, :present?, "State should be set"

    # Callback with WRONG state (simulating CSRF attack)
    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp", state: "completely_wrong_state"),
        headers: { "Host" => @host }

    # Should redirect with error
    assert_response :redirect

    # Session should be cleared on mismatch
    assert_nil session[SOCIAL_INTENT_SESSION_KEY], "Intent session should be cleared on state mismatch"

    # Follow redirect and verify error flash
    follow_redirect!
    assert_predicate flash[:alert], :present?, "Should have error flash message"
  end

  # ============================================================================
  # MANDATORY TEST 2: Apple POST callback with state mismatch -> 401
  # This test MUST FAIL if Apple is exempted from state validation
  # ============================================================================
  test "Apple POST callback with state mismatch returns error and clears session" do
    setup_apple_mock_auth(uid: "apple_mismatch_test")

    # Start OAuth flow
    get sign_app_social_start_url(provider: "apple", intent: "login", ri: "jp"),
        headers: { "Host" => @host }
    assert_response :redirect

    # Verify session
    assert_predicate session[SOCIAL_INTENT_SESSION_KEY], :present?, "Intent should be in session"
    original_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]
    assert_predicate original_state, :present?, "State should be set for Apple too"

    # Apple uses POST callback - simulate with WRONG state
    post sign_app_auth_callback_url(provider: "apple", ri: "jp"),
         params: { state: "wrong_apple_state_csrf_attempt" },
         headers: { "Host" => @host }

    # If Apple properly validates state, this should be a redirect with error
    assert_response :redirect, "Apple callback should redirect on state mismatch"

    # Session should be cleared
    assert_nil session[SOCIAL_INTENT_SESSION_KEY],
               "Intent session should be cleared on Apple state mismatch (state validation is required)"

    follow_redirect!
    assert_predicate flash[:alert], :present?, "Should have error flash for Apple state mismatch"
  end

  test "Apple GET callback with state mismatch also returns error" do
    setup_apple_mock_auth(uid: "apple_get_mismatch")

    get sign_app_social_start_url(provider: "apple", intent: "login", ri: "jp"),
        headers: { "Host" => @host }
    assert_response :redirect

    # GET callback with wrong state
    get sign_app_auth_callback_url(provider: "apple", ri: "jp", state: "wrong_get_state"),
        headers: { "Host" => @host }

    assert_response :redirect
    assert_nil session[SOCIAL_INTENT_SESSION_KEY]
  end

  test "Google callback without state parameter returns error" do
    setup_google_mock_auth(uid: "google_no_state")

    # Start flow
    get sign_app_social_start_url(provider: "google_oauth2", intent: "login", ri: "jp"),
        headers: { "Host" => @host }
    assert_response :redirect
    assert_predicate session[SOCIAL_INTENT_SESSION_KEY], :present?

    # Callback without state
    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp"),
        headers: { "Host" => @host }
    # Note: state is nil/empty

    assert_response :redirect
    assert_nil session[SOCIAL_INTENT_SESSION_KEY], "Session should be cleared when state is missing"
  end

  test "Apple callback without state parameter returns error" do
    setup_apple_mock_auth(uid: "apple_no_state")

    get sign_app_social_start_url(provider: "apple", intent: "login", ri: "jp"),
        headers: { "Host" => @host }
    assert_response :redirect
    assert_predicate session[SOCIAL_INTENT_SESSION_KEY], :present?

    # POST callback without state
    post sign_app_auth_callback_url(provider: "apple", ri: "jp"),
         params: {},
         headers: { "Host" => @host }

    assert_response :redirect
    assert_nil session[SOCIAL_INTENT_SESSION_KEY], "Session should be cleared when Apple state is missing"
  end

  # ============================================================================
  # OPTIONAL: State expired tests
  # ============================================================================
  test "Google callback with expired state returns error" do
    setup_google_mock_auth(uid: "google_expired")

    get sign_app_social_start_url(provider: "google_oauth2", intent: "login", ri: "jp"),
        headers: { "Host" => @host }
    assert_response :redirect

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    # Manually expire the session
    session[SOCIAL_INTENT_SESSION_KEY]["expires_at"] = 10.minutes.ago.iso8601

    # Callback with correct but expired state
    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp", state: valid_state),
        headers: { "Host" => @host }

    assert_response :redirect
    assert_nil session[SOCIAL_INTENT_SESSION_KEY], "Expired session should be cleared"
  end

  test "Apple callback with expired state returns error" do
    setup_apple_mock_auth(uid: "apple_expired")

    get sign_app_social_start_url(provider: "apple", intent: "login", ri: "jp"),
        headers: { "Host" => @host }
    assert_response :redirect

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]
    session[SOCIAL_INTENT_SESSION_KEY]["expires_at"] = 10.minutes.ago.iso8601

    post sign_app_auth_callback_url(provider: "apple", ri: "jp"),
         params: { state: valid_state },
         headers: { "Host" => @host }

    assert_response :redirect
    assert_nil session[SOCIAL_INTENT_SESSION_KEY]
  end

  # ============================================================================
  # Success case: Valid state passes validation
  # ============================================================================
  test "Google callback with valid state succeeds and creates user" do
    uid = "google_success_#{SecureRandom.hex(4)}"
    setup_google_mock_auth(uid: uid, email: "success@example.com")

    # Start flow
    get sign_app_social_start_url(provider: "google_oauth2", intent: "login", ri: "jp"),
        headers: { "Host" => @host }
    assert_response :redirect

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    user_count_before = User.count

    # Callback with correct state
    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp", state: valid_state),
        headers: { "Host" => @host }

    assert_response :redirect

    # Session should be cleared after success
    assert_nil session[SOCIAL_INTENT_SESSION_KEY], "Intent should be cleared after successful callback"

    # User should be created (this is the critical assertion)
    assert_equal user_count_before + 1, User.count, "New user should be created"
    assert UserSocialGoogle.exists?(uid: uid), "Google identity should exist"
  end

  test "Apple callback with valid state succeeds and creates user" do
    uid = "apple_success_#{SecureRandom.hex(4)}"
    setup_apple_mock_auth(uid: uid, email: "apple_success@example.com")

    get sign_app_social_start_url(provider: "apple", intent: "login", ri: "jp"),
        headers: { "Host" => @host }
    assert_response :redirect

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    user_count_before = User.count

    post sign_app_auth_callback_url(provider: "apple", ri: "jp"),
         params: { state: valid_state },
         headers: { "Host" => @host }

    assert_response :redirect
    assert_nil session[SOCIAL_INTENT_SESSION_KEY]

    # User should be created (critical assertions)
    assert_equal user_count_before + 1, User.count, "New user should be created"
    assert UserSocialApple.exists?(uid: uid), "Apple identity should exist"
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
        expires_at: 1.week.from_now.to_i,
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
        expires_at: 1.week.from_now.to_i,
      },
    )
  end
end
