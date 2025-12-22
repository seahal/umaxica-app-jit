require "test_helper"

class UserIdentitySocialGoogleTest < ActiveSupport::TestCase
  test "allows only one google auth per user" do
    user = users(:one)

    UserIdentitySocialGoogle.create!(
      user: user,
      uid: "uid-1",
      token: "token-1",
      expires_at: 1.week.from_now.to_i,
      user_identity_social_google_status: user_identity_social_google_statuses(:active)
    )

    duplicate = UserIdentitySocialGoogle.new(
      user: user,
      token: "token-2"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "はすでに存在します"
  end
end
