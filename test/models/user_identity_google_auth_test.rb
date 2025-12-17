require "test_helper"

class UserIdentityGoogleAuthTest < ActiveSupport::TestCase
  test "allows only one google auth per user" do
    user = users(:one)

    UserIdentityGoogleAuth.create!(
      user: user,
      token: "token-1",
      user_identity_google_auth_status: user_identity_google_auth_statuses(:active)
    )

    duplicate = UserIdentityGoogleAuth.new(
      user: user,
      token: "token-2"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "はすでに存在します"
  end
end
