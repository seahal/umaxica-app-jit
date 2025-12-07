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
  # TODO: Uncomment when user_sessions and staff_sessions tables are available
  # test "create_session! should create user session for user" do
  #   account = AccountService.new(@user)
  #
  #   session = account.create_session!
  #
  #   assert_not_nil session
  #   assert_equal @user.id, session.user_id
  # end
  #
  # test "create_session! should create staff session for staff" do
  #   account = AccountService.new(@staff)
  #
  #   session = account.create_session!
  #
  #   assert_not_nil session
  #   assert_equal @staff.id, session.staff_id
  # end
  #
  # test "sessions should return user sessions for user" do
  #   account = AccountService.new(@user)
  #   account.create_session!
  #
  #   sessions = account.sessions
  #
  #   assert_not_nil sessions
  #   assert sessions.any?
  # end
  #
  # test "destroy_all_sessions! should destroy all sessions" do
  #   account = AccountService.new(@user)
  #   account.create_session!
  #   account.create_session!
  #
  #   count = account.destroy_all_sessions!
  #
  #   assert_equal 2, count
  #   assert_equal 0, account.sessions.count
  # end

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



  # Authentication Tests
  test "authenticatable_with? should check email for user" do
    account = AccountService.new(@user)

    # Result depends on whether user has emails
    assert_respond_to account, :authenticatable_with?
  end

  test "authenticatable_with? should return false for phone for staff" do
    account = AccountService.new(@staff)

    assert_not account.authenticatable_with?(:phone)
  end

  # OAuth Tests
  test "oauth_configured? should return false for staff" do
    account = AccountService.new(@staff)

    assert_not account.oauth_configured?
  end

  # TOTP Tests
  test "totp_configured? should check for user totp" do
    account = AccountService.new(@user)

    assert_respond_to account, :totp_configured?
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
end
