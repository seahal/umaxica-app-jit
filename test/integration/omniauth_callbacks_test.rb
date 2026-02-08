# frozen_string_literal: true

require "test_helper"

class OmniauthCallbacksTest < ActionDispatch::IntegrationTest
  fixtures :user_social_google_statuses, :user_statuses, :user_one_time_password_statuses

  setup do
    OmniAuth.config.test_mode = true
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @expected_redirect = %r{\Ahttps?://#{Regexp.escape(@host)}/.*}.freeze
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:apple] = nil
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "should sign in with Google" do
    # IMPORTANT: Social login uses provider+uid ONLY, NOT email
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      {
        provider: "google_oauth2",
        uid: "123456789",
        info: {
          image: "http://example.com/image.jpg",
        },
        credentials: {
          token: "token",
          refresh_token: "refresh_token",
          expires_at: 1.week.from_now.to_i,
        },
      },
    )

    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp"),
        headers: SocialCallbackTestHelper.callback_headers(@host)
    assert_redirected_to @expected_redirect
    follow_redirect!

    user = UserSocialGoogle.find_by(uid: "123456789").user
    assert_not_nil user
  end

  test "should sign in with Apple" do
    # IMPORTANT: Social login uses provider+uid ONLY, NOT email
    OmniAuth.config.mock_auth[:apple] = OmniAuth::AuthHash.new(
      {
        provider: "apple",
        uid: "apple_uid_123",
        info: {},
        credentials: {
          token: "apple_token",
          expires_at: 1.week.from_now.to_i,
        },
      },
    )

    post sign_app_auth_callback_url(provider: "apple", ri: "jp"),
         headers: SocialCallbackTestHelper.callback_headers(@host)
    assert_redirected_to @expected_redirect
    follow_redirect!

    user = UserSocialApple.find_by(uid: "apple_uid_123").user
    assert_not_nil user
  end

  test "should sign in with existing Google user" do
    user = User.create!
    UserSocialGoogle.create!(
      user: user,
      uid: "existing_uid",
      provider: "google_oauth2",
      token: "existing_token",
      expires_at: 1.week.from_now.to_i,
      user_social_google_status: user_social_google_statuses(:active),
    )

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      {
        provider: "google_oauth2",
        uid: "existing_uid",
        info: {
          image: "http://example.com/image.jpg",
        },
        credentials: {
          token: "new_token",
          refresh_token: "new_refresh_token",
          expires_at: 1.week.from_now.to_i,
        },
      },
    )

    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp"),
        headers: SocialCallbackTestHelper.callback_headers(@host)
    assert_redirected_to @expected_redirect
    follow_redirect!

    provider_name = SocialIdentifiable.normalize_provider("google_oauth2").humanize
    assert_equal I18n.t("sign.app.social.sessions.create.already_registered", provider: provider_name), flash[:notice]
  end

  test "social login requiring mfa redirects to mfa hub and sets pending session" do
    user = User.create!
    UserOneTimePassword.create!(
      user: user,
      private_key: ROTP::Base32.random_base32,
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      title: "totp",
    )
    UserSocialGoogle.create!(
      user: user,
      uid: "totp_required_uid",
      provider: "google_oauth2",
      token: "existing_token",
      refresh_token: "existing_refresh",
      expires_at: 1.week.from_now.to_i,
      user_social_google_status: user_social_google_statuses(:active),
    )

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      {
        provider: "google_oauth2",
        uid: "totp_required_uid",
        info: { image: "http://example.com/image.jpg" },
        credentials: {
          token: "new_token",
          refresh_token: "new_refresh",
          expires_at: 1.week.from_now.to_i,
        },
      },
    )

    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp"),
        headers: SocialCallbackTestHelper.callback_headers(@host)

    assert_redirected_to sign_app_in_mfa_url(ri: "jp")
    assert_not_equal new_sign_app_in_url(ri: "jp"), response.redirect_url
    assert_equal user.id, session[:pending_mfa]["user_id"]
  end
end
