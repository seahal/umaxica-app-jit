# frozen_string_literal: true

require "test_helper"

class AccountablyServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @staff = staffs(:one)
  end

  # Initialization Tests
  test "should initialize with user" do
    accountably = AccountablyService.new(@user)

    assert_equal @user, accountably.accountably
    assert_equal :user, accountably.type
    assert_predicate accountably, :user?
  end

  test "should initialize with staff" do
    accountably = AccountablyService.new(@staff)

    assert_equal @staff, accountably.accountably
    assert_equal :staff, accountably.type
    assert_predicate accountably, :staff?
  end

  test "should raise error for invalid accountably" do
    assert_raises(ArgumentError) do
      AccountablyService.new("invalid")
    end
  end

  # Factory Method Tests
  test "find should return accountably service for user" do
    accountably = AccountablyService.find(@user.id)

    assert_not_nil accountably
    assert_predicate accountably, :user?
    assert_equal @user.id, accountably.id
  end

  test "find should return accountably service for staff" do
    accountably = AccountablyService.find(@staff.id)

    assert_not_nil accountably
    assert_predicate accountably, :staff?
    assert_equal @staff.id, accountably.id
  end

  test "find should return nil for non-existent id" do
    accountably = AccountablyService.find(SecureRandom.uuid)

    assert_nil accountably
  end

  test "find with type hint should find user" do
    accountably = AccountablyService.find(@user.id, type: :user)

    assert_not_nil accountably
    assert_predicate accountably, :user?
  end

  test "find with type hint should find staff" do
    accountably = AccountablyService.find(@staff.id, type: :staff)

    assert_not_nil accountably
    assert_predicate accountably, :staff?
  end

  test "find! should raise error for non-existent id" do
    assert_raises(ActiveRecord::RecordNotFound) do
      AccountablyService.find!(SecureRandom.uuid)
    end
  end

  test "find_by_email should return nil for blank email" do
    assert_nil AccountablyService.find_by(email: "")
    assert_nil AccountablyService.find_by(email: nil)
  end

  test "find_by_telephone should return nil for blank number" do
    assert_nil AccountablyService.find_by(telephone: "")
    assert_nil AccountablyService.find_by(telephone: nil)
  end

  test "find_by with email should find user" do
    email = "find_user@example.com"
    @user.user_identity_emails.create!(address: email, confirm_policy: true)

    accountably = AccountablyService.find_by(email: email)

    assert_not_nil accountably
    assert_equal @user.id, accountably.id
  end

  test "find_by with email should find staff" do
    email = "find_staff@example.com"
    @staff.staff_identity_emails.create!(address: email, confirm_policy: true)

    accountably = AccountablyService.find_by(email: email)

    assert_not_nil accountably
    assert_equal @staff.id, accountably.id
  end

  test "find_by with telephone should find user" do
    number = "1234567890"
    @user.user_identity_telephones.create!(
      number: number,
      confirm_policy: true,
      confirm_using_mfa: true,
    )

    accountably = AccountablyService.find_by(telephone: number)

    assert_not_nil accountably
    assert_equal @user.id, accountably.id
  end

  # Delegation Tests
  test "should delegate id to accountably" do
    accountably = AccountablyService.new(@user)

    assert_equal @user.id, accountably.id
  end

  test "should delegate created_at to accountably" do
    accountably = AccountablyService.new(@user)

    assert_equal @user.created_at, accountably.created_at
  end

  test "should delegate persisted? to accountably" do
    accountably = AccountablyService.new(@user)

    assert_equal @user.persisted?, accountably.persisted?
  end

  # Type Checking Tests
  test "user? should return true for user" do
    accountably = AccountablyService.new(@user)

    assert_predicate accountably, :user?
  end

  test "user? should return false for staff" do
    accountably = AccountablyService.new(@staff)

    assert_not accountably.user?
  end

  test "staff? should return true for staff" do
    accountably = AccountablyService.new(@staff)

    assert_predicate accountably, :staff?
  end

  test "staff? should return false for user" do
    accountably = AccountablyService.new(@user)

    assert_not accountably.staff?
  end

  # Duck Typing Tests

  test "is_a? should check underlying model" do
    user_accountably = AccountablyService.new(@user)

    assert_kind_of User, user_accountably
    assert_not user_accountably.is_a?(Staff)
  end

  test "kind_of? should work as alias for is_a?" do
    user_accountably = AccountablyService.new(@user)

    assert_kind_of User, user_accountably
    assert_not user_accountably.kind_of?(Staff)
  end

  # Session Management Tests
  test "create_session! should create user session for user" do
    accountably = AccountablyService.new(@user)

    assert_difference("UserToken.count", 1) do
      session = accountably.create_session!

      assert_not_nil session
      assert_equal @user.id, session.user_id
    end
  end

  test "create_session! should create staff session for staff" do
    accountably = AccountablyService.new(@staff)

    assert_difference("StaffToken.count", 1) do
      session = accountably.create_session!

      assert_not_nil session
      assert_equal @staff.id, session.staff_id
    end
  end

  test "sessions should return user tokens for user" do
    accountably = AccountablyService.new(@user)
    UserToken.where(user_id: @user.id).delete_all
    token = accountably.create_session!

    sessions = accountably.sessions

    assert_not_nil sessions
    assert_equal 1, sessions.count
    assert_equal token, sessions.first
  end

  test "sessions should return staff tokens for staff" do
    accountably = AccountablyService.new(@staff)
    StaffToken.where(staff_id: @staff.id).delete_all
    token = accountably.create_session!

    sessions = accountably.sessions

    assert_not_nil sessions
    assert_equal 1, sessions.count
    assert_equal token, sessions.first
  end

  test "destroy_all_sessions! should destroy all sessions for a user" do
    accountably = AccountablyService.new(@user)
    UserToken.where(user_id: @user.id).delete_all
    accountably.create_session! # creates first session
    accountably.create_session! # creates a second session

    assert_equal 2, accountably.sessions.count
    count = accountably.destroy_all_sessions!

    assert_equal 2, count
    assert_equal 0, accountably.sessions.count
  end

  # Identity Management Tests
  test "emails should delegate to accountably" do
    accountably = AccountablyService.new(@user)

    assert_respond_to accountably, :emails
  end

  test "phones should return phones for user" do
    accountably = AccountablyService.new(@user)

    assert_respond_to accountably, :phones
  end

  test "phones should return empty array for staff" do
    accountably = AccountablyService.new(@staff)

    assert_empty accountably.phones
  end

  test "primary_email returns the first email address" do
    accountably = AccountablyService.new(@user)

    assert_nil accountably.primary_email

    @user.user_identity_emails.create!(address: "first@example.com", confirm_policy: true)
    @user.user_identity_emails.create!(address: "second@example.com", confirm_policy: true)

    assert_equal "first@example.com", accountably.primary_email
  end

  test "primary_phone returns the first phone number" do
    accountably = AccountablyService.new(@user)

    assert_nil accountably.primary_phone

    @user.user_identity_telephones.create!(
      number: "111",
      confirm_policy: true,
      confirm_using_mfa: true,
    )
    @user.user_identity_telephones.create!(
      number: "222",
      confirm_policy: true,
      confirm_using_mfa: true,
    )

    assert_equal "111", accountably.primary_phone
  end

  # Authentication Tests
  test "authenticatable_with? returns false for email without identities" do
    accountably = AccountablyService.new(@user)

    assert_not accountably.authenticatable_with?(:email)
  end

  test "authenticatable_with? returns false for phone without identities" do
    accountably = AccountablyService.new(@user)

    assert_not accountably.authenticatable_with?(:phone)
  end

  test "authenticatable_with? returns false for webauthn without identities" do
    accountably = AccountablyService.new(@user)

    assert_not accountably.authenticatable_with?(:webauthn)
  end

  test "authenticatable_with? returns false for oauth without identities" do
    accountably = AccountablyService.new(@user)

    assert_not accountably.authenticatable_with?(:oauth)
  end

  test "authenticatable_with? returns false for totp without identities" do
    accountably = AccountablyService.new(@user)

    assert_not accountably.authenticatable_with?(:totp)
  end

  test "available_authentication_methods is empty without identities" do
    accountably = AccountablyService.new(@user)

    assert_empty accountably.available_authentication_methods
  end

  test "authenticatable_with? returns true for email and phone with identities" do
    accountably = AccountablyService.new(@user)

    add_user_identities(@user)

    assert accountably.authenticatable_with?(:email)
    assert accountably.authenticatable_with?(:phone)
  end

  test "available_authentication_methods returns expected list" do
    accountably = AccountablyService.new(@user)

    add_user_identities(@user)

    assert_equal %i(email oauth phone), accountably.available_authentication_methods.sort
  end

  test "staff authenticatable_with? supports email only" do
    accountably = AccountablyService.new(@staff)

    add_staff_email(@staff)

    assert accountably.authenticatable_with?(:email)
    assert_not accountably.authenticatable_with?(:phone)
  end

  # OAuth Tests
  test "oauth_configured? should return true for user with oauth" do
    accountably = AccountablyService.new(@user)

    assert_not accountably.oauth_configured?
    @user.create_user_identity_social_apple!(
      uid: "testval",
      token: "test_oauth_token",
      expires_at: 1.week.from_now.to_i,
    )

    assert_predicate accountably, :oauth_configured?
  end

  test "oauth_configured? should return false for staff" do
    accountably = AccountablyService.new(@staff)

    assert_not accountably.oauth_configured?
  end

  # TOTP Tests
  test "totp_configured? should check for user totp" do
    accountably = AccountablyService.new(@user)

    assert_not accountably.totp_configured?
    # UserTimeBasedOneTimePassword.create!(user: @user, secret: "secret")
    # assert accountably.totp_configured?
  end

  # Model Access Tests
  test "to_model should return underlying model" do
    accountably = AccountablyService.new(@user)

    assert_equal @user, accountably.to_model
  end

  test "to_s should return string representation" do
    accountably = AccountablyService.new(@user)

    string = accountably.to_s

    assert_match(/AccountablyService/, string)
    assert_match(/user/, string)
    assert_match(/#{@user.id}/, string)
  end

  test "inspect should return detailed string representation" do
    accountably = AccountablyService.new(@user)
    @user.user_identity_emails.create!(address: "inspect@example.com", confirm_policy: true)

    string = accountably.inspect

    assert_match(/AccountablyService/, string)
    assert_match(/inspect@example.com/, string)
  end

  private

  # Helper method to add various identities to a user for testing
  def add_user_identities(user)
    user.user_identity_emails.create!(address: "test@example.com", confirm_policy: true)
    user.user_identity_telephones.create!(
      number: "123-456-7890",
      confirm_policy: true,
      confirm_using_mfa: true,
    )
    unless user.user_identity_social_apple
      user.create_user_identity_social_apple!(
        uid: "testval_#{SecureRandom.hex(8)}",
        token: "test_apple_token_#{SecureRandom.hex(8)}",
        expires_at: 1.week.from_now.to_i,
      )
    end
  end

  # Helper method to add email to staff for testing
  def add_staff_email(staff)
    staff.staff_identity_emails.create!(address: "staff@example.com", confirm_policy: true)
  end
end
