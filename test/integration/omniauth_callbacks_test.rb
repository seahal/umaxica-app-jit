# frozen_string_literal: true

require "test_helper"

class OmniauthCallbacksTest < ActionDispatch::IntegrationTest
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
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      {
        provider: "google_oauth2",
        uid: "123456789",
        info: {
          email: "test@example.com",
          image: "http://example.com/image.jpg",
        },
        credentials: {
          token: "token",
          refresh_token: "refresh_token",
          expires_at: 1.week.from_now.to_i,
        },
      },
    )

    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp"), headers: { "Host" => @host }
    assert_redirected_to @expected_redirect
    follow_redirect!

    SocialIdentifiable.normalize_provider("google_oauth2").humanize
    assert_equal I18n.t("sign.app.social.sessions.create.success", provider: "Google"), flash[:notice]

    user = UserSocialGoogle.find_by(uid: "123456789").user
    assert_not_nil user
  end

  test "should sign in with Apple" do
    OmniAuth.config.mock_auth[:apple] = OmniAuth::AuthHash.new(
      {
        provider: "apple",
        uid: "apple_uid_123",
        info: {
          email: "apple@example.com",
        },
        credentials: {
          token: "apple_token",
          expires_at: 1.week.from_now.to_i,
        },
      },
    )

    get sign_app_auth_callback_url(provider: "apple", ri: "jp"), headers: { "Host" => @host }
    assert_redirected_to @expected_redirect
    follow_redirect!

    assert_equal I18n.t("sign.app.social.sessions.create.success", provider: "Apple"), flash[:notice]

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
          email: "existing@example.com",
          image: "http://example.com/image.jpg",
        },
        credentials: {
          token: "new_token",
          refresh_token: "new_refresh_token",
          expires_at: 1.week.from_now.to_i,
        },
      },
    )

    get sign_app_auth_callback_url(provider: "google_oauth2", ri: "jp"), headers: { "Host" => @host }
    assert_redirected_to @expected_redirect
    follow_redirect!

    provider_name = SocialIdentifiable.normalize_provider("google_oauth2").humanize
    assert_equal I18n.t("sign.app.social.sessions.create.already_registered", provider: provider_name), flash[:notice]
  end
end
