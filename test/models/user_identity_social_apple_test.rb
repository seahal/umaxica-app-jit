# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_social_apples
#
#  id                                   :uuid             not null, primary key
#  created_at                           :datetime         not null
#  email                                :string           default(""), not null
#  expires_at                           :integer          not null
#  image                                :string           default(""), not null
#  provider                             :string           default("apple"), not null
#  refresh_token                        :string           default(""), not null
#  token                                :string           default(""), not null
#  uid                                  :string           default(""), not null
#  updated_at                           :datetime         not null
#  user_id                              :uuid             not null
#  user_identity_social_apple_status_id :string(255)      default("ACTIVE"), not null
#
# Indexes
#
#  idx_on_user_identity_social_apple_status_id_d1764af59f  (user_identity_social_apple_status_id)
#  index_user_identity_social_apples_on_expires_at         (expires_at)
#  index_user_identity_social_apples_on_uid_and_provider   (uid,provider) UNIQUE
#  index_user_identity_social_apples_on_user_id_unique     (user_id) UNIQUE
#

require "test_helper"

class UserIdentitySocialAppleTest < ActiveSupport::TestCase
  fixtures :users, :user_identity_statuses, :user_identity_social_apples, :user_identity_social_apple_statuses

  test "allows only one apple auth per user" do
    user = User.find_by!(public_id: "one_id")

    UserIdentitySocialApple.create!(
      user: user,
      uid: "uid-1",
      token: "token-1",
      expires_at: 1.week.from_now.to_i,
      user_identity_social_apple_status: UserIdentitySocialAppleStatus.find("ACTIVE"),
    )

    duplicate = UserIdentitySocialApple.new(
      user: user,
      token: "token-2",
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "はすでに存在します"
  end

  test "token is required" do
    identity = UserIdentitySocialApple.new(user: User.find_by!(public_id: "one_id"), uid: "uid", expires_at: 123)
    assert_not identity.valid?
    assert_not_empty identity.errors[:token]
  end

  test "uid is required" do
    identity = UserIdentitySocialApple.new(user: User.find_by!(public_id: "one_id"), token: "token", expires_at: 123)
    assert_not identity.valid?
    assert_not_empty identity.errors[:uid]
  end

  test "expires_at is required" do
    identity = UserIdentitySocialApple.new(user: User.find_by!(public_id: "one_id"), uid: "uid", token: "token")
    assert_not identity.valid?
    assert_not_empty identity.errors[:expires_at]
  end

  test "association deletion: destroys when user is destroyed" do
    user = User.create!
    identity = UserIdentitySocialApple.create!(
      user: user,
      uid: "uid-cleanup",
      token: "token-cleanup",
      expires_at: 1.week.from_now.to_i,
    )
    user.destroy
    assert_raise(ActiveRecord::RecordNotFound) { identity.reload }
  end
end
