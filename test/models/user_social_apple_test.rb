# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_apples
#
#  id                          :uuid             not null, primary key
#  token                       :string           default(""), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  user_social_apple_status_id :string(255)      default("ACTIVE"), not null
#  user_id                     :uuid             not null
#  uid                         :string           default(""), not null
#  email                       :string           default(""), not null
#  image                       :string           default(""), not null
#  refresh_token               :string           default(""), not null
#  expires_at                  :integer          not null
#  provider                    :string           default("apple"), not null
#
# Indexes
#
#  idx_on_user_identity_social_apple_status_id_d1764af59f  (user_social_apple_status_id)
#  index_user_identity_social_apples_on_expires_at         (expires_at)
#  index_user_identity_social_apples_on_uid_and_provider   (uid,provider) UNIQUE
#  index_user_identity_social_apples_on_user_id_unique     (user_id) UNIQUE
#

require "test_helper"

class UserSocialAppleTest < ActiveSupport::TestCase
  fixtures :users, :user_statuses, :user_social_apples, :user_social_apple_statuses

  test "allows only one apple auth per user" do
    user = User.find_by!(public_id: "one_id")

    UserSocialApple.create!(
      user: user,
      uid: "uid-1",
      token: "token-1",
      expires_at: 1.week.from_now.to_i,
      user_social_apple_status: UserSocialAppleStatus.find("ACTIVE"),
    )

    duplicate = UserSocialApple.new(
      user: user,
      token: "token-2",
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "はすでに存在します"
  end

  test "token is required" do
    identity = UserSocialApple.new(user: User.find_by!(public_id: "one_id"), uid: "uid", expires_at: 123)
    assert_not identity.valid?
    assert_not_empty identity.errors[:token]
  end

  test "uid is required" do
    identity = UserSocialApple.new(user: User.find_by!(public_id: "one_id"), token: "token", expires_at: 123)
    assert_not identity.valid?
    assert_not_empty identity.errors[:uid]
  end

  test "expires_at is required" do
    identity = UserSocialApple.new(user: User.find_by!(public_id: "one_id"), uid: "uid", token: "token")
    assert_not identity.valid?
    assert_not_empty identity.errors[:expires_at]
  end

  test "association deletion: destroys when user is destroyed" do
    user = User.create!
    identity = UserSocialApple.create!(
      user: user,
      uid: "uid-cleanup",
      token: "token-cleanup",
      expires_at: 1.week.from_now.to_i,
    )
    user.destroy
    assert_raise(ActiveRecord::RecordNotFound) { identity.reload }
  end

  test "find_or_create_from_auth_hash initializes new record" do
    auth = MockAuth.new(
      uid: "new-uid",
      provider: "apple",
      info: OpenStruct.new(email: "test@example.com"),
      credentials: OpenStruct.new(token: "new-token", expires_at: 123),
    )

    identity = UserSocialApple.find_or_create_from_auth_hash(auth)

    assert_predicate identity, :new_record?
    assert_equal "new-uid", identity.uid
    assert_equal "apple", identity.provider
    assert_equal "test@example.com", identity.email
    assert_equal "new-token", identity.token
    assert_equal 123, identity.expires_at
  end

  test "find_or_create_from_auth_hash returns existing record with updated attributes" do
    user = users(:one)
    UserSocialApple.create!(
      user: user,
      uid: "existing-uid",
      token: "old-token",
      expires_at: 123,
      user_social_apple_status: UserSocialAppleStatus.find("ACTIVE"),
    )

    auth = MockAuth.new(
      uid: "existing-uid",
      provider: "apple",
      info: OpenStruct.new(email: "updated@example.com"),
      credentials: OpenStruct.new(token: "updated-token", expires_at: 456),
    )

    identity = UserSocialApple.find_or_create_from_auth_hash(auth)

    assert_predicate identity, :persisted?
    assert_equal "updated-token", identity.token
    assert_equal 456, identity.expires_at
    # Ensure it didn't save yet if that's the behavior, or did it?
    # find_or_initialize returns the object. It modifies it but doesn't save.
    assert_equal "updated-token", identity.token
    assert identity.changes.key?("token") # Confirms it has unsaved changes
  end

  class MockAuth < OpenStruct; end
end
