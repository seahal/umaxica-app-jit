require "test_helper"

class OmniauthCallbacksTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:apple] = nil
  end

  test "should sign in with Google" do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "123456789",
      info: {
        email: "test@example.com",
        image: "http://example.com/image.jpg"
      },
      credentials: {
        token: "token",
        refresh_token: "refresh_token",
        expires_at: 1.week.from_now.to_i
      }
    })

    get sign_app_social_google_callback_url, headers: { "Host" => @host }
    assert_redirected_to %r{\Ahttp://sign\.umaxica\.app/.*}
    follow_redirect!

    assert_equal I18n.t("sign.app.social.sessions.create.success", provider: "Google oauth2"), flash[:notice]

    user = UserIdentitySocialGoogle.find_by(uid: "123456789").user
    assert_not_nil user
    assert_equal "test@example.com", user.user_identity_social_google.email
  end

  test "should sign in with Apple" do
    OmniAuth.config.mock_auth[:apple] = OmniAuth::AuthHash.new({
      provider: "apple",
      uid: "apple_uid_123",
      info: {
        email: "apple@example.com"
      },
      credentials: {
        token: "apple_token",
        expires_at: 1.week.from_now.to_i
      }
    })

    get sign_app_social_apple_callback_url, headers: { "Host" => @host }
    assert_redirected_to %r{\Ahttp://sign\.umaxica\.app/.*}
    follow_redirect!

    assert_equal I18n.t("sign.app.social.sessions.create.success", provider: "Apple"), flash[:notice]

    user = UserIdentitySocialApple.find_by(uid: "apple_uid_123").user
    assert_not_nil user
    assert_equal "apple@example.com", user.user_identity_social_apple.email
  end

  test "should sign in with existing Google user" do
    user = User.create!
    UserIdentitySocialGoogle.create!(
      user: user,
      uid: "existing_uid",
      provider: "google_oauth2",
      token: "existing_token",
      email: "existing@example.com",
      user_identity_social_google_status: user_identity_social_google_statuses(:active)
    )

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "existing_uid",
      info: {
        email: "existing@example.com",
        image: "http://example.com/image.jpg"
      },
      credentials: {
        token: "new_token",
        refresh_token: "new_refresh_token",
        expires_at: 1.week.from_now.to_i
      }
    })

    get sign_app_social_google_callback_url, headers: { "Host" => @host }
    assert_redirected_to %r{\Ahttp://sign\.umaxica\.app/.*}
    follow_redirect!

    assert_equal I18n.t("sign.app.social.sessions.create.success", provider: "Google oauth2"), flash[:notice]
  end

  test "should link to existing user if email matches? (Not implemented logic yet)" do
    # My current implementation creates a NEW user if identity not found.
    # Future improvement: Link by email.
    skip "Not implemented yet"
  end
end
