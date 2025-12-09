# frozen_string_literal: true

require "test_helper"

# Test with UserIdentityEmail which includes Email
class EmailTest < ActiveSupport::TestCase
  test "concern can be included in a class" do
    assert_includes UserIdentityEmail.included_modules, Email
  end

  test "concern adds confirm_policy accessor" do
    email = UserIdentityEmail.new

    assert_respond_to email, :confirm_policy
    assert_respond_to email, :confirm_policy=
  end

  test "concern adds pass_code accessor" do
    email = UserIdentityEmail.new

    assert_respond_to email, :pass_code
    assert_respond_to email, :pass_code=
  end

  test "downcases address before save" do
    email = UserIdentityEmail.new(address: "TEST@EXAMPLE.COM", confirm_policy: true)
    email.save!

    assert_equal "test@example.com", email.address
  end

  test "encrypts address deterministically" do
    email1 = UserIdentityEmail.create!(address: "test1@example.com", confirm_policy: true)
    email2 = UserIdentityEmail.create!(address: "test2@example.com", confirm_policy: true)

    # Different emails should have different encrypted values
    raw1 = UserIdentityEmail.connection.execute(
      UserIdentityEmail.sanitize_sql_array([ "SELECT address FROM user_identity_emails WHERE id = ?", email1.id ])
    ).first
    raw2 = UserIdentityEmail.connection.execute(
      UserIdentityEmail.sanitize_sql_array([ "SELECT address FROM user_identity_emails WHERE id = ?", email2.id ])
    ).first

    assert_not_equal raw1["address"], raw2["address"]
  end

  test "validates email format with basic formats" do
    assert_predicate UserIdentityEmail.new(address: "test@example.com", confirm_policy: true), :valid?
    assert_predicate UserIdentityEmail.new(address: "user+tag@example.co.jp", confirm_policy: true), :valid?
  end

  test "validates email format with consecutive special characters" do
    assert_predicate UserIdentityEmail.new(address: "user+tag@example.co.uk", confirm_policy: true), :valid?
    assert_predicate UserIdentityEmail.new(address: "user+tag+123@example.com", confirm_policy: true), :valid?
  end

  test "validates email format with dots and underscores" do
    assert_predicate UserIdentityEmail.new(address: "user.name@example.com", confirm_policy: true), :valid?
    assert_predicate UserIdentityEmail.new(address: "user_name@example.co.uk", confirm_policy: true), :valid?
  end

  test "validates email format with multiple domain levels" do
    assert_predicate UserIdentityEmail.new(address: "user@mail.example.co.uk", confirm_policy: true), :valid?
    assert_predicate UserIdentityEmail.new(address: "user.tag@sub.example.com", confirm_policy: true), :valid?
  end

  test "validates email format with Gmail-style addressing" do
    assert_predicate UserIdentityEmail.new(address: "user+mailbox@gmail.com", confirm_policy: true), :valid?
  end

  test "validates email format with mixed special characters" do
    assert_predicate UserIdentityEmail.new(address: "user-name_tag+123@example.co.uk", confirm_policy: true), :valid?
  end

  test "validates email format with numeric addresses" do
    assert_predicate UserIdentityEmail.new(address: "1234567890@example.com", confirm_policy: true), :valid?
  end

  test "validates email format with single label domains and localhost" do
    assert_predicate UserIdentityEmail.new(address: "user@localhost", confirm_policy: true), :valid?
    assert_predicate UserIdentityEmail.new(address: "user@example", confirm_policy: true), :valid?
  end

  test "rejects invalid email formats" do
    assert_not UserIdentityEmail.new(address: "invalid-email", confirm_policy: true).valid?
    assert_not UserIdentityEmail.new(address: "user@", confirm_policy: true).valid?
    assert_not UserIdentityEmail.new(address: "@example.com", confirm_policy: true).valid?
  end

  test "rejects email with spaces" do
    assert_not UserIdentityEmail.new(address: "user @example.com", confirm_policy: true).valid?
  end

  test "validates email presence" do
    email = UserIdentityEmail.new(address: nil, confirm_policy: true)

    assert_not email.valid?
    assert_predicate email.errors[:address], :any?
  end

  test "validates uniqueness of address case insensitively" do
    UserIdentityEmail.create!(address: "test@example.com", confirm_policy: true)
    duplicate = UserIdentityEmail.new(address: "TEST@EXAMPLE.COM", confirm_policy: true)

    assert_not duplicate.valid?
    assert_predicate duplicate.errors[:address], :any?
  end

  test "validates confirm_policy acceptance" do
    email = UserIdentityEmail.new(address: "test@example.com", confirm_policy: false)

    assert_not email.valid?
    assert_predicate email.errors[:confirm_policy], :any?
  end

  test "increment_attempts! increases otp_attempts_count atomically" do
    email = UserIdentityEmail.create!(address: "test@example.com", confirm_policy: true)
    initial_count = email.otp_attempts_count

    email.increment_attempts!

    assert_equal initial_count + 1, email.reload.otp_attempts_count
  end

  test "locked? returns false when attempts < 3" do
    email = UserIdentityEmail.create!(address: "test@example.com", confirm_policy: true)

    assert_not email.locked?

    email.increment_attempts!

    assert_not email.reload.locked?

    email.increment_attempts!

    assert_not email.reload.locked?
  end

  test "locked? returns true when attempts >= 3" do
    email = UserIdentityEmail.create!(address: "test@example.com", confirm_policy: true)

    3.times { email.increment_attempts! }

    assert_predicate email.reload, :locked?
  end

  test "locked? returns true when locked_at is set" do
    email = UserIdentityEmail.create!(address: "test@example.com", confirm_policy: true)
    email.update!(locked_at: Time.current)

    assert_predicate email, :locked?
  end

  test "clear_otp resets attempts and locked_at" do
    email = UserIdentityEmail.create!(address: "test@example.com", confirm_policy: true)
    3.times { email.increment_attempts! }
    email.update!(locked_at: Time.current)

    email.clear_otp

    assert_equal 0, email.otp_attempts_count
    assert_nil email.locked_at
  end

  test "increment_attempts! is thread-safe under concurrent access" do
    email = UserIdentityEmail.create!(address: "concurrent@example.com", confirm_policy: true)

    # rubocop:disable ThreadSafety/NewThread
    threads = 10.times.map do
      Thread.new do
        10.times do
          ActiveRecord::Base.connection_pool.with_connection do
            # Use a fresh instance to better simulate concurrent requests
            UserIdentityEmail.find(email.id).increment_attempts!
          end
        end
      end
    end

    threads.each(&:join)

    # rubocop:enable ThreadSafety/NewThread
    assert_equal 100, email.reload.otp_attempts_count
  end
end
