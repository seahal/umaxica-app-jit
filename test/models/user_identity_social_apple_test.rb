require "test_helper"

class UserIdentitySocialAppleTest < ActiveSupport::TestCase
  test "allows only one apple auth per user" do
    user = users(:one)

    UserIdentitySocialApple.create!(
      user: user,
      uid: "uid-1",
      token: "token-1",
      user_identity_social_apple_status: user_identity_social_apple_statuses(:active)
    )

    duplicate = UserIdentitySocialApple.new(
      user: user,
      token: "token-2"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "はすでに存在します"
  end
end
