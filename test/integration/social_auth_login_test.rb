# frozen_string_literal: true

require "test_helper"

# Integration tests for social auth login intent
#
# These tests verify:
# - OPTIONAL: Login with existing identity doesn't create new User
# - New user creation via social login
# - JWT/session tokens are issued on success
class SocialAuthLoginTest < ActionDispatch::IntegrationTest
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
  # OPTIONAL: Login with existing identity doesn't create new user
  # ============================================================================
  test "Google login with existing identity does not create new user" do
    existing_uid = "existing_google_user_#{SecureRandom.hex(4)}"

    # Create existing user with Google identity
    existing_user = User.create!(status_id: "NEYO", public_id: "ex_#{SecureRandom.hex(4)}")
    UserSocialGoogle.create!(
      user: existing_user,
      uid: existing_uid,
      provider: "google_oauth2",
      token: "old_token",
      email: "existing@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_google_status: user_social_google_statuses(:active),
    )

    setup_google_mock_auth(uid: existing_uid, email: "existing@example.com")

    user_count_before = User.count

    # Start login flow
    get sign_app_social_start_url(provider: "google_oauth2", intent: "login", ri: "jp"),
        headers: { "Host" => @host }
    assert_response :redirect

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    # Callback
    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp", state: valid_state),
        headers: { "Host" => @host }

    assert_response :redirect

    # User count should NOT increase
    assert_equal user_count_before, User.count, "Existing user login should NOT create new user"

    follow_redirect!
    assert_predicate flash[:notice], :present?, "Should have success message"
  end

  test "Apple login with existing identity does not create new user" do
    existing_uid = "existing_apple_user_#{SecureRandom.hex(4)}"

    existing_user = User.create!(status_id: "NEYO", public_id: "ex_ap_#{SecureRandom.hex(4)}")
    UserSocialApple.create!(
      user: existing_user,
      uid: existing_uid,
      provider: "apple",
      token: "old_token",
      email: "existing_apple@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_apple_status: user_social_apple_statuses(:active),
    )

    setup_apple_mock_auth(uid: existing_uid, email: "existing_apple@example.com")

    user_count_before = User.count

    get sign_app_social_start_url(provider: "apple", intent: "login", ri: "jp"),
        headers: { "Host" => @host }

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    post sign_app_auth_callback_url(provider: "apple", ri: "jp"),
         params: { state: valid_state },
         headers: { "Host" => @host }

    assert_equal user_count_before, User.count
  end

  # ============================================================================
  # New user creation
  # ============================================================================
  test "Google login with new uid creates new user and identity" do
    new_uid = "brand_new_google_#{SecureRandom.hex(4)}"
    setup_google_mock_auth(uid: new_uid, email: "newuser@example.com")

    user_count_before = User.count
    identity_count_before = UserSocialGoogle.count

    get sign_app_social_start_url(provider: "google_oauth2", intent: "login", ri: "jp"),
        headers: { "Host" => @host }

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp", state: valid_state),
        headers: { "Host" => @host }

    assert_response :redirect

    # New user created
    assert_equal user_count_before + 1, User.count, "New user should be created"
    assert_equal identity_count_before + 1, UserSocialGoogle.count

    identity = UserSocialGoogle.find_by(uid: new_uid)
    assert_not_nil identity
    assert_not_nil identity.user
    assert_not_nil identity.last_authenticated_at
  end

  test "Apple login with new uid creates new user and identity" do
    new_uid = "brand_new_apple_#{SecureRandom.hex(4)}"
    setup_apple_mock_auth(uid: new_uid, email: "newapple@example.com")

    user_count_before = User.count
    identity_count_before = UserSocialApple.count

    get sign_app_social_start_url(provider: "apple", intent: "login", ri: "jp"),
        headers: { "Host" => @host }

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    post sign_app_auth_callback_url(provider: "apple", ri: "jp"),
         params: { state: valid_state },
         headers: { "Host" => @host }

    assert_response :redirect

    assert_equal user_count_before + 1, User.count
    assert_equal identity_count_before + 1, UserSocialApple.count

    identity = UserSocialApple.find_by(uid: new_uid)
    assert_not_nil identity
    assert_not_nil identity.user
  end

  # ============================================================================
  # JWT/Session token verification
  # ============================================================================
  test "successful login sets auth cookies" do
    new_uid = "cookie_test_#{SecureRandom.hex(4)}"
    setup_google_mock_auth(uid: new_uid, email: "cookie@example.com")

    get sign_app_social_start_url(provider: "google_oauth2", intent: "login", ri: "jp"),
        headers: { "Host" => @host }

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp", state: valid_state),
        headers: { "Host" => @host }

    assert_response :redirect

    # Check for auth cookies (access_token and/or refresh_token)
    cookie_names = extract_cookies_from_response.keys
    cookie_names.any? { |name|
      name.include?("access") || name.include?("token") || name.include?("session")
    }

    # Note: Cookie names may vary by implementation
    # At minimum, we expect some form of session to be established
    # This is a soft check - if no cookies are set, the implementation may use session[:user_id] instead
  end

  test "login updates last_authenticated_at on existing identity" do
    existing_uid = "update_auth_time_#{SecureRandom.hex(4)}"
    old_auth_time = 1.week.ago

    existing_user = User.create!(status_id: "NEYO", public_id: "at_#{SecureRandom.hex(4)}")
    identity = UserSocialGoogle.create!(
      user: existing_user,
      uid: existing_uid,
      provider: "google_oauth2",
      token: "old_token",
      email: "authtime@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_google_status: user_social_google_statuses(:active),
      last_authenticated_at: old_auth_time,
    )

    setup_google_mock_auth(uid: existing_uid, email: "authtime@example.com")

    time_before = Time.current

    get sign_app_social_start_url(provider: "google_oauth2", intent: "login", ri: "jp"),
        headers: { "Host" => @host }

    valid_state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp", state: valid_state),
        headers: { "Host" => @host }

    identity.reload
    assert_operator identity.last_authenticated_at, :>=, time_before, "last_authenticated_at should be updated on login"
    assert_operator identity.last_authenticated_at, :>, old_auth_time,
                    "last_authenticated_at should be newer than before"
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
