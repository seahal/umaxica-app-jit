# frozen_string_literal: true

require "test_helper"

class SocialAuthServiceTest < ActiveSupport::TestCase
  fixtures :user_statuses, :user_social_google_statuses

  test "social login assigns user status during user creation" do
    auth_hash = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google_uid_status_test",
      credentials: {
        token: "test_token",
        expires_at: 1.week.from_now.to_i,
      },
    )

    result = SocialAuthService.handle_callback(auth_hash: auth_hash, current_user: nil, intent: "login")

    assert_equal UserStatus::UNVERIFIED_WITH_SIGN_UP, result[:user].status_id
  end
end
