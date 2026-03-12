# typed: false
# frozen_string_literal: true

require "test_helper"

class AuthMethodGuardTest < ActiveSupport::TestCase
  fixtures :users

  test "remaining_count returns 0 for user with no methods" do
    user = users(:one)
    UserSocialGoogle.where(user: user).delete_all
    UserSocialApple.where(user: user).delete_all
    UserEmail.where(user: user).delete_all
    UserTelephone.where(user: user).delete_all

    assert_equal 0, AuthMethodGuard.remaining_count(user)
  end

  test "remaining_count includes active Google identity" do
    user = users(:one)
    UserSocialGoogle.where(user: user).delete_all
    UserSocialApple.where(user: user).delete_all

    UserSocialGoogle.create!(
      user: user,
      uid: "test_google_#{SecureRandom.hex(4)}",
      provider: "google_app",
      user_identity_social_google_status_id: UserSocialGoogleStatus::ACTIVE,
      token: "token",
      expires_at: 1.week.from_now.to_i,
    )

    assert_equal 1, AuthMethodGuard.remaining_count(user)
  end

  test "remaining_count includes active Apple identity" do
    user = users(:one)
    UserSocialGoogle.where(user: user).delete_all
    UserSocialApple.where(user: user).delete_all

    UserSocialApple.create!(
      user: user,
      uid: "test_apple_#{SecureRandom.hex(4)}",
      provider: "apple",
      user_identity_social_apple_status_id: UserSocialAppleStatus::ACTIVE,
      token: "token",
      expires_at: 1.week.from_now.to_i,
    )

    assert_equal 1, AuthMethodGuard.remaining_count(user)
  end

  test "remaining_count includes verified emails" do
    user = users(:one)
    UserSocialGoogle.where(user: user).delete_all
    UserSocialApple.where(user: user).delete_all
    UserEmail.where(user: user).delete_all

    UserEmail.create!(
      user: user,
      address: "test#{SecureRandom.hex(4)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
    )

    assert_equal 1, AuthMethodGuard.remaining_count(user)
  end

  test "remaining_count excludes unverified emails" do
    user = users(:one)
    UserEmail.where(user: user).delete_all

    UserEmail.create!(
      user: user,
      address: "unverified#{SecureRandom.hex(4)}@example.com",
      user_email_status_id: UserEmailStatus::UNVERIFIED,
    )

    assert_equal 0, AuthMethodGuard.remaining_count(user)
  end

  test "remaining_count includes verified telephones" do
    user = users(:one)
    UserTelephone.where(user: user).delete_all

    UserTelephone.create!(
      user: user,
      number: "+819012345678",
      user_identity_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )

    assert_equal 1, AuthMethodGuard.remaining_count(user)
  end

  test "remaining_count excludes unverified telephones" do
    user = users(:one)
    UserTelephone.where(user: user).delete_all

    UserTelephone.create!(
      user: user,
      number: "+819012345678",
      user_identity_telephone_status_id: UserTelephoneStatus::UNVERIFIED,
    )

    assert_equal 0, AuthMethodGuard.remaining_count(user)
  end

  test "remaining_count excludes specified identity" do
    user = users(:one)
    UserSocialGoogle.where(user: user).delete_all

    google = UserSocialGoogle.create!(
      user: user,
      uid: "test_google_#{SecureRandom.hex(4)}",
      provider: "google_app",
      user_identity_social_google_status_id: UserSocialGoogleStatus::ACTIVE,
      token: "token",
      expires_at: 1.week.from_now.to_i,
    )

    assert_equal 0, AuthMethodGuard.remaining_count(user, excluding: google)
  end

  test "last_method returns true when only one method exists" do
    user = users(:one)
    UserSocialGoogle.where(user: user).delete_all
    UserSocialApple.where(user: user).delete_all
    UserEmail.where(user: user).delete_all
    UserTelephone.where(user: user).delete_all

    google = UserSocialGoogle.create!(
      user: user,
      uid: "test_google_#{SecureRandom.hex(4)}",
      provider: "google_app",
      user_identity_social_google_status_id: UserSocialGoogleStatus::ACTIVE,
      token: "token",
      expires_at: 1.week.from_now.to_i,
    )

    assert_equal 1, AuthMethodGuard.remaining_count(user)
    assert AuthMethodGuard.last_method?(user, excluding: google)
  end

  test "last_method returns false when multiple methods exist" do
    user = users(:one)
    UserSocialGoogle.where(user: user).delete_all
    UserEmail.where(user: user).delete_all

    UserSocialGoogle.create!(
      user: user,
      uid: "test_google_#{SecureRandom.hex(4)}",
      provider: "google_app",
      user_identity_social_google_status_id: UserSocialGoogleStatus::ACTIVE,
      token: "token",
      expires_at: 1.week.from_now.to_i,
    )

    UserEmail.create!(
      user: user,
      address: "test#{SecureRandom.hex(4)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
    )

    assert_not AuthMethodGuard.last_method?(user)
  end

  test "remaining_count counts multiple methods correctly" do
    user = users(:one)
    UserSocialGoogle.where(user: user).delete_all
    UserSocialApple.where(user: user).delete_all
    UserEmail.where(user: user).delete_all
    UserTelephone.where(user: user).delete_all

    UserSocialGoogle.create!(
      user: user,
      uid: "test_google_#{SecureRandom.hex(4)}",
      provider: "google_app",
      user_identity_social_google_status_id: UserSocialGoogleStatus::ACTIVE,
      token: "token",
      expires_at: 1.week.from_now.to_i,
    )

    UserSocialApple.create!(
      user: user,
      uid: "test_apple_#{SecureRandom.hex(4)}",
      provider: "apple",
      user_identity_social_apple_status_id: UserSocialAppleStatus::ACTIVE,
      token: "token",
      expires_at: 1.week.from_now.to_i,
    )

    UserEmail.create!(
      user: user,
      address: "test#{SecureRandom.hex(4)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
    )

    assert_equal 3, AuthMethodGuard.remaining_count(user)
  end

  test "remaining_count excludes inactive Google identity" do
    user = users(:one)
    UserSocialGoogle.where(user: user).delete_all

    UserSocialGoogle.create!(
      user: user,
      uid: "test_google_#{SecureRandom.hex(4)}",
      provider: "google_app",
      user_identity_social_google_status_id: UserSocialGoogleStatus::REVOKED,
      token: "token",
      expires_at: 1.week.from_now.to_i,
    )

    assert_equal 0, AuthMethodGuard.remaining_count(user)
  end
end
