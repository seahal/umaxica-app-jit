# == Schema Information
#
# Table name: user_identity_secrets
#
#  id                             :uuid             not null, primary key
#  created_at                     :datetime         not null
#  expires_at                     :datetime         default("infinity"), not null
#  last_used_at                   :datetime         default("-infinity"), not null
#  name                           :string           default(""), not null
#  password_digest                :string           default(""), not null
#  updated_at                     :datetime         not null
#  user_id                        :uuid             not null
#  user_identity_secret_status_id :string(255)      default("ACTIVE"), not null
#
# Indexes
#
#  index_user_identity_secrets_on_expires_at                      (expires_at)
#  index_user_identity_secrets_on_user_id                         (user_id)
#  index_user_identity_secrets_on_user_identity_secret_status_id  (user_identity_secret_status_id)
#

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
        name: "Secret-#{SecureRandom.hex(4)}",
        password: "SecurePass123!",
        password_confirmation: "SecurePass123!"
      )
    end
end
