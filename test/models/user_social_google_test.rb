# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_googles
# Database name: principal
#
#  id                                    :bigint           not null, primary key
#  expires_at                            :integer          not null
#  image                                 :string           default(""), not null
#  last_authenticated_at                 :datetime
#  provider                              :string           default("google_oauth2"), not null
#  refresh_token                         :string           default(""), not null
#  token                                 :string           default(""), not null
#  uid                                   :string           default(""), not null
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  user_id                               :bigint           not null
#  user_identity_social_google_status_id :bigint           default(0), not null
#
# Indexes
#
#  idx_on_user_identity_social_google_status_id_f4bfb6ffdd  (user_identity_social_google_status_id)
#  index_user_identity_social_googles_on_user_id_unique     (user_id) UNIQUE WHERE (user_id IS NOT NULL)
#  index_user_social_googles_on_expires_at                  (expires_at)
#  index_user_social_googles_on_uid_and_provider            (uid,provider) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (user_identity_social_google_status_id => user_social_google_statuses.id)
#

require "test_helper"

class UserSocialGoogleTest < ActiveSupport::TestCase
  fixtures :users, :user_social_google_statuses, :user_social_googles

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
    assert_equal "http://image.com", identity.image
    assert_equal "google-token", identity.token
    assert_equal 123, identity.expires_at
  end

  test "find_or_create_from_auth_hash handles missing image" do
    auth = MockAuth.new(
      uid: "no-image-uid",
      provider: "google_oauth2",
      info: OpenStruct.new(email: "google@example.com", image: ""),
      credentials: OpenStruct.new(token: "google-token", expires_at: 123),
    )

    identity = UserSocialGoogle.find_or_create_from_auth_hash(auth)

    assert_equal "", identity.image
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

  test "extract_uid falls back to extra raw_info sub" do
    auth = MockAuth.new(
      uid: "",
      provider: "google_oauth2",
      info: OpenStruct.new(email: "google@example.com", image: "http://image.com"),
      credentials: OpenStruct.new(token: "google-token", expires_at: 123),
      extra: OpenStruct.new(raw_info: OpenStruct.new(sub: "fallback-sub")),
    )

    assert_equal "fallback-sub", UserSocialGoogle.extract_uid(auth)
  end

  test "update_from_auth_hash updates attributes and timestamp" do
    identity = UserSocialGoogle.create!(
      user: users(:one),
      uid: "update-google-uid",
      token: "old-token",
      refresh_token: "old-refresh",
      expires_at: 123,
      image: "old-image",
    )

    auth = MockAuth.new(
      uid: "update-google-uid",
      provider: "google_oauth2",
      info: OpenStruct.new(email: "new-google@example.com", image: "new-image"),
      credentials: OpenStruct.new(token: "new-token", refresh_token: "new-refresh", expires_at: 456),
    )

    assert_nil identity.last_authenticated_at
    identity.update_from_auth_hash!(auth)

    assert_equal "new-image", identity.image
    assert_equal "new-token", identity.token
    assert_equal "new-refresh", identity.refresh_token
    assert_equal 456, identity.expires_at
    assert_predicate identity.last_authenticated_at, :present?
  end

  test "active scope and active? check status column" do
    active = UserSocialGoogle.create!(
      user: users(:two),
      uid: "active-google-uid",
      token: "token",
      expires_at: 123,
      user_identity_social_google_status_id: "ACTIVE",
    )

    inactive = UserSocialGoogle.create!(
      user: User.create!,
      uid: "inactive-google-uid",
      token: "token",
      expires_at: 123,
      user_identity_social_google_status_id: "REVOKED",
    )

    assert_includes UserSocialGoogle.active, active
    assert_not_includes UserSocialGoogle.active, inactive
    assert_predicate active, :active?
    assert_not inactive.active?
  end

  test "normalized_provider maps provider" do
    identity = UserSocialGoogle.new(provider: "google_oauth2")
    assert_equal "google", identity.normalized_provider
  end

  class MockAuth < OpenStruct; end
end
