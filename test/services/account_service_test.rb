# frozen_string_literal: true

require "test_helper"

class AccountServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @staff = staffs(:one)
  end

  # Initialization Tests
  test "should initialize with user" do
    account = AccountService.new(@user)

    assert_equal @user, account.accountable
    assert_equal :user, account.type
    assert_predicate account, :user?
  end

  test "should initialize with staff" do
    account = AccountService.new(@staff)

    assert_equal @staff, account.accountable
    assert_equal :staff, account.type
    assert_predicate account, :staff?
  end

  test "should raise error for invalid accountable" do
    assert_raises(ArgumentError) do
      AccountService.new("invalid")
    end
  end

  # Factory Method Tests
  test "find should return account service for user" do
    account = AccountService.find(@user.id)

    assert_not_nil account
    assert_predicate account, :user?
    assert_equal @user.id, account.id
  end

  test "find should return account service for staff" do
    account = AccountService.find(@staff.id)

    assert_not_nil account
    assert_predicate account, :staff?
    assert_equal @staff.id, account.id
  end

  test "find should return nil for non-existent id" do
    account = AccountService.find(SecureRandom.uuid)

    assert_nil account
  end

  test "find with type hint should find user" do
    account = AccountService.find(@user.id, type: :user)

    assert_not_nil account
    assert_predicate account, :user?
  end

  test "find with type hint should find staff" do
    account = AccountService.find(@staff.id, type: :staff)

    assert_not_nil account
    assert_predicate account, :staff?
  end

  test "find! should raise error for non-existent id" do
    assert_raises(ActiveRecord::RecordNotFound) do
      AccountService.find!(SecureRandom.uuid)
    end
  end

  test "find_by_email should return nil for blank email" do
    assert_nil AccountService.find_by(email: "")
    assert_nil AccountService.find_by(email: nil)
  end

  test "find_by_telephone should return nil for blank number" do
    assert_nil AccountService.find_by(telephone: "")
    assert_nil AccountService.find_by(telephone: nil)
  end

  test "find_by with email should find user" do
    email = "find_user@example.com"
    @user.user_identity_emails.create!(address: email, confirm_policy: true)

    account = AccountService.find_by(email: email)

    assert_not_nil account
    assert_equal @user.id, account.id
  end

  test "find_by with email should find staff" do
    email = "find_staff@example.com"
    @staff.staff_identity_emails.create!(address: email, confirm_policy: true)

    account = AccountService.find_by(email: email)

    assert_not_nil account
    assert_equal @staff.id, account.id
  end

  test "find_by with telephone should find user" do
    number = "1234567890"
    @user.user_identity_telephones.create!(
      number: number,
      confirm_policy: true,
      confirm_using_mfa: true,
    )

    account = AccountService.find_by(telephone: number)

    assert_not_nil account
    assert_equal @user.id, account.id
  end

  # Delegation Tests
  test "should delegate id to accountable" do
    account = AccountService.new(@user)

    assert_equal @user.id, account.id
  end

  test "should delegate created_at to accountable" do
    account = AccountService.new(@user)

    assert_equal @user.created_at, account.created_at
  end

  test "should delegate persisted? to accountable" do
    account = AccountService.new(@user)

    assert_equal @user.persisted?, account.persisted?
  end

  # Type Checking Tests
  test "user? should return true for user" do
    account = AccountService.new(@user)

    assert_predicate account, :user?
  end

  test "user? should return false for staff" do
    account = AccountService.new(@staff)

    assert_not account.user?
  end

  test "staff? should return true for staff" do
    account = AccountService.new(@staff)

    assert_predicate account, :staff?
  end

  test "staff? should return false for user" do
    account = AccountService.new(@user)

    assert_not account.staff?
  end

  # Duck Typing Tests

  test "is_a? should check underlying model" do
    user_account = AccountService.new(@user)

    assert_kind_of User, user_account
    assert_not user_account.is_a?(Staff)
  end

  test "kind_of? should work as alias for is_a?" do
    user_account = AccountService.new(@user)

    assert_kind_of User, user_account
    assert_not user_account.kind_of?(Staff)
  end

  # Session Management Tests
  test "create_session! should create user session for user" do
    account = AccountService.new(@user)

    assert_difference("UserToken.count", 1) do
      session = account.create_session!

      assert_not_nil session
      assert_equal @user.id, session.user_id
    end
  end

  test "create_session! should create staff session for staff" do
    account = AccountService.new(@staff)

    assert_difference("StaffToken.count", 1) do
      session = account.create_session!

      assert_not_nil session
      assert_equal @staff.id, session.staff_id
    end
  end

  test "sessions should return user tokens for user" do
    account = AccountService.new(@user)
    UserToken.where(user_id: @user.id).delete_all
    token = account.create_session!

    sessions = account.sessions

    assert_not_nil sessions
    assert_equal 1, sessions.count
    assert_equal token, sessions.first
  end

  test "sessions should return staff tokens for staff" do
    account = AccountService.new(@staff)
    StaffToken.where(staff_id: @staff.id).delete_all
    token = account.create_session!

    sessions = account.sessions

    assert_not_nil sessions
    assert_equal 1, sessions.count
    assert_equal token, sessions.first
  end

  test "destroy_all_sessions! should destroy all sessions for a user" do
    account = AccountService.new(@user)
    UserToken.where(user_id: @user.id).delete_all
    account.create_session! # creates first session
    account.create_session! # creates a second session

    assert_equal 2, account.sessions.count
    count = account.destroy_all_sessions!

    assert_equal 2, count
    assert_equal 0, account.sessions.count
  end

  # Identity Management Tests
  test "emails should delegate to accountable" do
    account = AccountService.new(@user)

    assert_respond_to account, :emails
  end

  test "phones should return phones for user" do
    account = AccountService.new(@user)

    assert_respond_to account, :phones
  end

  test "phones should return empty array for staff" do
    account = AccountService.new(@staff)

    assert_empty account.phones
  end

  test "primary_email returns the first email address" do
    account = AccountService.new(@user)

    assert_nil account.primary_email

    @user.user_identity_emails.create!(address: "first@example.com", confirm_policy: true)
    @user.user_identity_emails.create!(address: "second@example.com", confirm_policy: true)

    assert_equal "first@example.com", account.primary_email
  end

  test "primary_phone returns the first phone number" do
    account = AccountService.new(@user)

    assert_nil account.primary_phone

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

    assert_equal "111", account.primary_phone
  end

  # Authentication Tests
  test "authenticatable_with? returns false for email without identities" do
    account = AccountService.new(@user)

    assert_not account.authenticatable_with?(:email)
  end

  test "authenticatable_with? returns false for phone without identities" do
    account = AccountService.new(@user)

    assert_not account.authenticatable_with?(:phone)
  end

  test "authenticatable_with? returns false for webauthn without identities" do
    account = AccountService.new(@user)

    assert_not account.authenticatable_with?(:webauthn)
  end

  test "authenticatable_with? returns false for oauth without identities" do
    account = AccountService.new(@user)

    assert_not account.authenticatable_with?(:oauth)
  end

  test "authenticatable_with? returns false for totp without identities" do
    account = AccountService.new(@user)

    assert_not account.authenticatable_with?(:totp)
  end

  test "available_authentication_methods is empty without identities" do
    account = AccountService.new(@user)

    assert_empty account.available_authentication_methods
  end

  test "authenticatable_with? returns true for email and phone with identities" do
    account = AccountService.new(@user)

    add_user_identities(@user)

    assert account.authenticatable_with?(:email)
    assert account.authenticatable_with?(:phone)
  end

  test "available_authentication_methods returns expected list" do
    account = AccountService.new(@user)

    add_user_identities(@user)

    assert_equal %i(email oauth phone), account.available_authentication_methods.sort
  end

  test "staff authenticatable_with? supports email only" do
    account = AccountService.new(@staff)

    add_staff_email(@staff)

    assert account.authenticatable_with?(:email)
    assert_not account.authenticatable_with?(:phone)
  end

  # OAuth Tests
  test "oauth_configured? should return true for user with oauth" do
    account = AccountService.new(@user)

    assert_not account.oauth_configured?
    @user.create_user_identity_social_apple!(uid: "testval",
                                             token: "test_oauth_token",
                                             expires_at: 1.week.from_now.to_i,)

    assert_predicate account, :oauth_configured?
  end

  test "oauth_configured? should return false for staff" do
    account = AccountService.new(@staff)

    assert_not account.oauth_configured?
  end

  # TOTP Tests
  test "totp_configured? should check for user totp" do
    account = AccountService.new(@user)

    assert_not account.totp_configured?
    # UserTimeBasedOneTimePassword.create!(user: @user, secret: "secret")
    # assert account.totp_configured?
  end

  # Model Access Tests
  test "to_model should return underlying model" do
    account = AccountService.new(@user)

    assert_equal @user, account.to_model
  end

  test "to_s should return string representation" do
    account = AccountService.new(@user)

    string = account.to_s

    assert_match(/AccountService/, string)
    assert_match(/user/, string)
    assert_match(/#{@user.id}/, string)
  end

  test "inspect should return detailed string representation" do
    account = AccountService.new(@user)
    @user.user_identity_emails.create!(address: "inspect@example.com", confirm_policy: true)

    string = account.inspect

    assert_match(/AccountService/, string)
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
      user.create_user_identity_social_apple!(uid: "testval_#{SecureRandom.hex(8)}",
                                              token: "test_apple_token_#{SecureRandom.hex(8)}",
                                              expires_at: 1.week.from_now.to_i,)
    end
  end

  # Helper method to add email to staff for testing
  def add_staff_email(staff)
    staff.staff_identity_emails.create!(address: "staff@example.com", confirm_policy: true)
  end
end
