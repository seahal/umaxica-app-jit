# frozen_string_literal: true

require "test_helper"

class AppleAuthTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    CloudflareTurnstile.test_mode = true
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
  end

  teardown do
    OmniAuth.config.mock_auth[:apple] = nil
  end

  test "should create new user with unverified status on first login" do
    OmniAuth.config.mock_auth[:apple] = OmniAuth::AuthHash.new(
      {
        provider: "apple",
        uid: "apple_uid_new",
        info: {
          email: "new_apple@example.com",
        },
        credentials: {
          token: "apple_token",
          expires_at: 1.week.from_now.to_i,
        },
      },
    )

    get sign_app_auth_callback_url(provider: "apple", ri: "jp"), headers: { "Host" => @host }
    assert_redirected_to edit_sign_app_configuration_email_url(UserEmail.last.public_id, ri: "jp")
    follow_redirect!

    user = UserSocialApple.find_by(uid: "apple_uid_new").user
    assert_equal "UNVERIFIED_WITH_SIGN_UP", user.status_id
    assert_equal "UNVERIFIED_WITH_SIGN_UP", UserEmail.last.user_email_status_id
  end

  test "should sign in existing user normally" do
    user = User.create!(status_id: "ACTIVE")
    UserSocialApple.create!(
      user: user,
      uid: "apple_uid_existing",
      provider: "apple",
      token: "existing_token",
      email: "existing@example.com",
      expires_at: 1.week.from_now.to_i,
    )

    OmniAuth.config.mock_auth[:apple] = OmniAuth::AuthHash.new(
      {
        provider: "apple",
        uid: "apple_uid_existing",
        info: {
          email: "existing@example.com",
        },
        credentials: {
          token: "new_token",
          expires_at: 1.week.from_now.to_i,
        },
      },
    )

    get sign_app_auth_callback_url(provider: "apple", ri: "jp"), headers: { "Host" => @host }
    assert_redirected_to sign_app_configuration_url(ri: "jp")

    assert_equal I18n.t("sign.app.social.sessions.create.already_registered", provider: "Apple"), flash[:notice]
  end
end
