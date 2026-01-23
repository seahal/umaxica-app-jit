# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_googles
#
#  id                                    :uuid             not null, primary key
#  token                                 :string           default(""), not null
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  user_identity_social_google_status_id :string(255)      default("ACTIVE"), not null
#  user_id                               :uuid             not null
#  uid                                   :string           default(""), not null
#  email                                 :string           default(""), not null
#  image                                 :string           default(""), not null
#  refresh_token                         :string           default(""), not null
#  expires_at                            :integer          not null
#  provider                              :string           default("google_oauth2"), not null
#  last_authenticated_at                 :datetime
#
# Indexes
#
#  idx_on_user_identity_social_google_status_id_f4bfb6ffdd  (user_identity_social_google_status_id)
#  index_user_identity_social_googles_on_user_id_unique     (user_id) UNIQUE
#  index_user_social_googles_on_expires_at                  (expires_at)
#  index_user_social_googles_on_uid_and_provider            (uid,provider) UNIQUE
#

require "test_helper"

class UserSocialGoogleTest < ActiveSupport::TestCase
  test "allows only one google auth per user" do
    user = User.find_by!(public_id: "one_id")

    UserSocialGoogle.create!(
      user: user,
      uid: "uid-1",
      token: "token-1",
      expires_at: 1.week.from_now.to_i,
      user_social_google_status: UserSocialGoogleStatus.find("ACTIVE"),
    )

    duplicate = UserSocialGoogle.new(
      user: user,
      token: "token-2",
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:user_id]
  end

  test "token is required" do
    identity = UserSocialGoogle.new(user: User.find_by!(public_id: "one_id"), uid: "uid", expires_at: 123)
    assert_not identity.valid?
    assert_not_empty identity.errors[:token]
  end

  test "uid is required" do
    identity = UserSocialGoogle.new(user: User.find_by!(public_id: "one_id"), token: "token", expires_at: 123)
    assert_not identity.valid?
    assert_not_empty identity.errors[:uid]
  end

  test "expires_at is required" do
    identity = UserSocialGoogle.new(user: User.find_by!(public_id: "one_id"), uid: "uid", token: "token")
    assert_not identity.valid?
    assert_not_empty identity.errors[:expires_at]
  end

  test "association deletion: destroys when user is destroyed" do
    user = User.create!
    identity = UserSocialGoogle.create!(
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
      uid: "new-google-uid",
      provider: "google_oauth2",
      info: OpenStruct.new(email: "google@example.com", image: "http://image.com"),
      credentials: OpenStruct.new(token: "google-token", expires_at: 123),
    )

    identity = UserSocialGoogle.find_or_create_from_auth_hash(auth)

    assert_predicate identity, :new_record?
    assert_equal "new-google-uid", identity.uid
    assert_equal "google_oauth2", identity.provider
    assert_equal "google@example.com", identity.email
    assert_equal "http://image.com", identity.image
    assert_equal "google-token", identity.token
    assert_equal 123, identity.expires_at
  end

  test "find_or_create_from_auth_hash returns existing record with updated attributes" do
    user = users(:one)
    UserSocialGoogle.create!(
      user: user,
      uid: "existing-google-uid",
      token: "old-token",
      expires_at: 123,
      user_social_google_status: UserSocialGoogleStatus.find("ACTIVE"),
    )

    auth = MockAuth.new(
      uid: "existing-google-uid",
      provider: "google_oauth2",
      info: OpenStruct.new(email: "updated-google@example.com", image: "http://new-image.com"),
      credentials: OpenStruct.new(token: "updated-token", expires_at: 456),
    )

    identity = UserSocialGoogle.find_or_create_from_auth_hash(auth)

    assert_predicate identity, :persisted?
    assert_equal "updated-token", identity.token
    assert_equal "http://new-image.com", identity.image
    assert identity.changes.key?("token")
  end

  class MockAuth < OpenStruct; end
end
