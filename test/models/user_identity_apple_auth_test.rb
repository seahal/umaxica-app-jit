require "test_helper"

class UserIdentityAppleAuthTest < ActiveSupport::TestCase
  test "allows only one apple auth per user" do
    user = users(:one)

    UserIdentityAppleAuth.create!(
      user: user,
      token: "token-1",
      user_identity_apple_auth_status: user_identity_apple_auth_statuses(:active)
    )

    duplicate = UserIdentityAppleAuth.new(
      user: user,
      token: "token-2"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "はすでに存在します"
  end
end
