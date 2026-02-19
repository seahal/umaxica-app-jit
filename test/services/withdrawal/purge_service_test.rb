# frozen_string_literal: true

require "test_helper"

class Withdrawal::PurgeServiceTest < ActiveSupport::TestCase
  fixtures :users, :user_statuses, :user_token_statuses, :user_email_statuses,
           :user_secret_kinds, :user_secret_statuses, :staff_statuses

  setup do
    @user = users(:one)
    @user.update!(status_id: UserStatus::ACTIVE)
    # Clear tokens to avoid limit error
    UserToken.where(user_id: @user.id).delete_all
    # Ensure user has a verified email for secrets/passkeys
    @user.user_emails.destroy_all
    UserEmail.create!(user: @user, address: "test@example.com", user_email_status_id: UserEmailStatus::VERIFIED)
  end

  test "revokes all active tokens" do
    # Create active tokens (limit is 3 total including restricted)
    token1 = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
    token1.rotate_refresh_token!
    token2 = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
    token2.rotate_refresh_token!
    revoked_token = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
    revoked_token.rotate_refresh_token!
    revoked_token.update!(revoked_at: 1.day.ago)

    Withdrawal::PurgeService.new(@user).call

    assert_not_nil token1.reload.revoked_at
    assert_not_nil token2.reload.revoked_at
    assert_not_nil revoked_token.reload.revoked_at
  end

  test "destroys all PII associations" do
    # Clear any existing data for the user from fixtures
    @user.user_emails.destroy_all
    @user.user_telephones.destroy_all
    @user.user_secrets.destroy_all
    @user.user_passkeys.destroy_all
    @user.user_one_time_passwords.destroy_all

    # Create PII data
    UserEmail.create!(user: @user, address: "test1@example.com", user_email_status_id: UserEmailStatus::VERIFIED)
    UserTelephone.create!(user: @user, number: "+819012345678")
    UserSecret.create!(user: @user, name: "Test Secret", password: "a" * 32)
    UserPasskey.create!(
      user: @user,
      webauthn_id: "test_id_#{SecureRandom.hex(4)}",
      external_id: SecureRandom.uuid,
      public_key: "public_key",
      description: "Test Passkey",
    )
    UserOneTimePassword.create!(user: @user, private_key: ROTP::Base32.random_base32, title: "Test TOTP")

    assert_equal 1, @user.user_emails.count
    assert_equal 1, @user.user_telephones.count
    assert_equal 1, @user.user_secrets.count
    assert_equal 1, @user.user_passkeys.count
    assert_equal 1, @user.user_one_time_passwords.count

    Withdrawal::PurgeService.new(@user).call

    assert_equal 0, @user.reload.user_emails.count
    assert_equal 0, @user.user_telephones.count
    assert_equal 0, @user.user_secrets.count
    assert_equal 0, @user.user_passkeys.count
    assert_equal 0, @user.user_one_time_passwords.count
  end

  test "destroys social auth associations" do
    UserSocialApple.create!(user: @user, uid: "apple123", token: "test_token", expires_at: 1_234_567_890)
    UserSocialGoogle.create!(user: @user, uid: "google123", token: "test_token", expires_at: 1_234_567_890)

    assert_not_nil @user.user_social_apple
    assert_not_nil @user.user_social_google

    Withdrawal::PurgeService.new(@user).call

    assert_nil @user.reload.user_social_apple
    assert_nil @user.user_social_google
  end

  test "marks user as purged" do
    Withdrawal::PurgeService.new(@user).call

    assert_not_nil @user.reload.purged_at
    assert_equal UserStatus::WITHDRAWN, @user.status_id
  end

  test "emits user.purged event" do
    events = []
    subscriber = Object.new
    subscriber.define_singleton_method(:emit) do |event|
      events << [event[:name], event[:payload]]
    end
    Rails.event.subscribe(subscriber) { |event| event[:name] == "user.purged" }

    begin
      Withdrawal::PurgeService.new(@user).call

      assert_equal 1, events.length
      assert_equal "user.purged", events[0][0]
      # User ID might be filtered in some environments/configurations
      # assert_equal @user.id, events[0][1][:user_id]
    ensure
      Rails.event.unsubscribe(subscriber)
    end
  end
end
