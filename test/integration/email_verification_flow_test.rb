# typed: false
# frozen_string_literal: true

require "test_helper"

class EmailVerificationFlowTest < ActionDispatch::IntegrationTest
  setup do
    CloudflareTurnstile.test_mode = true
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = User.create!(status_id: UserStatus::UNVERIFIED_WITH_SIGN_UP)
  end

  test "social login flow does not trigger email verification and redirects to checkpoint" do
    OmniAuth.config.test_mode = true
    # IMPORTANT: Social login uses provider+uid ONLY, NOT email
    OmniAuth.config.mock_auth[:apple] = OmniAuth::AuthHash.new(
      {
        provider: "apple",
        uid: "flow_uid",
        info: {},
        credentials: { token: "token", expires_at: 1.week.from_now.to_i },
      },
    )

    # 1. Start Auth callback
    # We expect NO emails to be sent
    assert_no_emails do
      post sign_app_auth_callback_url(provider: "apple", ri: "jp"),
           headers: SocialCallbackTestHelper.callback_headers(@host)
    end

    assert_response :redirect
    follow_redirect!

    # Verify we are on checkpoint page, NOT email verification page
    assert_equal sign_app_in_checkpoint_path, path

    # User status should still be UNVERIFIED_WITH_SIGN_UP if it was new,
    # but no UserEmail should have been created from the IdP info
    user = UserSocialApple.find_by(uid: "flow_uid").user
    assert_nil UserEmail.find_by(user: user)
  end
end
