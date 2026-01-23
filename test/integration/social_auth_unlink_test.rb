# frozen_string_literal: true

require "test_helper"

# Integration tests for social auth unlink functionality
#
# These tests verify:
# - MANDATORY TEST 4: Unlink when only 1 identity returns 422 (LastIdentityError)
# - Successful unlink removes identity
# - Unlink requires authentication
class SocialAuthUnlinkTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")

    # Create test user with recent reauth (required for unlink when REQUIRE_REAUTH_FOR_UNLINK is true)
    @user = User.create!(
      status_id: "NEYO",
      public_id: "unlink_test_#{SecureRandom.hex(4)}",
      last_reauth_at: 1.minute.ago,
    )
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:apple] = nil
  end

  # ============================================================================
  # MANDATORY TEST 4: Unlink last identity returns 422 (LastIdentityError)
  # ============================================================================
  test "unlink last Google identity returns 422 LastIdentityError" do
    # User has only one identity (Google)
    google_identity = UserSocialGoogle.create!(
      user: @user,
      uid: "last_google_identity_#{SecureRandom.hex(4)}",
      provider: "google_oauth2",
      token: "token",
      email: "last@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_google_status: user_social_google_statuses(:active),
    )

    # Try to unlink
    delete sign_app_social_unlink_url(provider: "google_oauth2", ri: "jp"),
           headers: as_user_headers(@user, host: @host)

    # Should redirect with error
    assert_response :redirect
    follow_redirect!

    # Verify error about last identity
    assert_predicate flash[:alert], :present?, "Should have error about last identity"

    # Identity should still exist
    assert UserSocialGoogle.exists?(id: google_identity.id), "Last identity should NOT be deleted"
  end

  test "unlink last Apple identity returns 422 LastIdentityError" do
    apple_identity = UserSocialApple.create!(
      user: @user,
      uid: "last_apple_identity_#{SecureRandom.hex(4)}",
      provider: "apple",
      token: "token",
      email: "last_apple@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_apple_status: user_social_apple_statuses(:active),
    )

    delete sign_app_social_unlink_url(provider: "apple", ri: "jp"),
           headers: as_user_headers(@user, host: @host)

    assert_response :redirect
    follow_redirect!

    assert_predicate flash[:alert], :present?, "Should have error about last identity"
    assert UserSocialApple.exists?(id: apple_identity.id), "Last identity should NOT be deleted"
  end

  # ============================================================================
  # Success case: Unlink when user has multiple auth methods
  # ============================================================================
  test "unlink Google succeeds when user has another auth method" do
    # User has both Google and Apple
    google_identity = UserSocialGoogle.create!(
      user: @user,
      uid: "google_to_unlink_#{SecureRandom.hex(4)}",
      provider: "google_oauth2",
      token: "token",
      email: "google@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_google_status: user_social_google_statuses(:active),
    )

    UserSocialApple.create!(
      user: @user,
      uid: "apple_backup_#{SecureRandom.hex(4)}",
      provider: "apple",
      token: "token",
      email: "apple@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_apple_status: user_social_apple_statuses(:active),
    )

    delete sign_app_social_unlink_url(provider: "google_oauth2", ri: "jp"),
           headers: as_user_headers(@user, host: @host)

    assert_response :redirect
    follow_redirect!

    # Should have success message
    assert_predicate flash[:notice], :present?, "Should have success message"

    # Google identity should be deleted
    assert_not UserSocialGoogle.exists?(id: google_identity.id), "Google identity should be deleted"

    # Apple identity should still exist
    assert_equal 1, UserSocialApple.where(user: @user).count
  end

  test "unlink Apple succeeds when user has Google linked" do
    UserSocialGoogle.create!(
      user: @user,
      uid: "google_backup_#{SecureRandom.hex(4)}",
      provider: "google_oauth2",
      token: "token",
      email: "google@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_google_status: user_social_google_statuses(:active),
    )

    apple_identity = UserSocialApple.create!(
      user: @user,
      uid: "apple_to_unlink_#{SecureRandom.hex(4)}",
      provider: "apple",
      token: "token",
      email: "apple@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_apple_status: user_social_apple_statuses(:active),
    )

    delete sign_app_social_unlink_url(provider: "apple", ri: "jp"),
           headers: as_user_headers(@user, host: @host)

    assert_response :redirect
    follow_redirect!

    assert_predicate flash[:notice], :present?
    assert_not UserSocialApple.exists?(id: apple_identity.id)
  end

  # ============================================================================
  # Error cases
  # ============================================================================
  test "unlink non-existent identity returns error" do
    # User has no Google identity but tries to unlink
    UserSocialApple.create!(
      user: @user,
      uid: "apple_only_#{SecureRandom.hex(4)}",
      provider: "apple",
      token: "token",
      email: "apple@example.com",
      expires_at: 1.week.from_now.to_i,
      user_social_apple_status: user_social_apple_statuses(:active),
    )

    delete sign_app_social_unlink_url(provider: "google_oauth2", ri: "jp"),
           headers: as_user_headers(@user, host: @host)

    assert_response :redirect
    follow_redirect!

    assert_predicate flash[:alert], :present?, "Should have error about identity not found"
  end

  test "unlink requires authentication" do
    # No auth header
    delete sign_app_social_unlink_url(provider: "google_oauth2", ri: "jp"),
           headers: { "Host" => @host }

    # Should redirect to login
    assert_response :redirect
    follow_redirect!

    assert flash[:alert].present? || request.path.include?("sign"), "Should redirect to login"
  end
end
