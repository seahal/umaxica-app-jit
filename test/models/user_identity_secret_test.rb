require "test_helper"

class UserIdentitySecretTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "allows up to the maximum number of secrets per user" do
    UserIdentitySecret::MAX_SECRETS_PER_USER.times do
      create_secret!
    end

    assert_equal UserIdentitySecret::MAX_SECRETS_PER_USER,
                 UserIdentitySecret.where(user: @user).count
  end

  test "rejects creating more than the maximum secrets per user" do
    UserIdentitySecret::MAX_SECRETS_PER_USER.times { create_secret! }

    assert_raises(ActiveRecord::RecordInvalid) { create_secret! }
  end

  private

  def create_secret!
    UserIdentitySecret.create!(
      user: @user,
      password: "SecurePass123!",
      password_confirmation: "SecurePass123!"
    )
  end
end
