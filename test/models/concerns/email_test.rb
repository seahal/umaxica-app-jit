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

  # OTP method tests
  # rubocop:disable Minitest/MultipleAssertions
  test "store_otp stores OTP configuration" do
    email = UserIdentityEmail.create!(address: "otp@example.com", confirm_policy: true)
    otp_key = "secret_key_123"
    otp_counter = 10
    expires_at = 1.hour.from_now.to_i

    email.store_otp(otp_key, otp_counter, expires_at)

    assert_equal otp_key, email.otp_private_key
    assert_equal otp_counter.to_s, email.otp_counter.to_s
    assert_equal 0, email.otp_attempts_count
    assert_nil email.locked_at
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "get_otp returns OTP configuration when valid" do
    email = UserIdentityEmail.create!(address: "otp2@example.com", confirm_policy: true)
    otp_key = "secret_key_456"
    otp_counter = 20
    expires_at = 1.hour.from_now.to_i

    email.store_otp(otp_key, otp_counter, expires_at)
    otp_data = email.get_otp

    assert_not_nil otp_data
    assert_equal otp_key, otp_data[:otp_private_key]
    assert_equal otp_counter, otp_data[:otp_counter]
  end

  test "get_otp returns nil when OTP is expired" do
    email = UserIdentityEmail.create!(address: "otp3@example.com", confirm_policy: true)
    otp_key = "secret_key_789"
    otp_counter = 30
    expires_at = 1.hour.ago.to_i  # Already expired

    email.store_otp(otp_key, otp_counter, expires_at)
    otp_data = email.get_otp

    assert_nil otp_data
  end

  test "get_otp returns nil when OTP is locked" do
    email = UserIdentityEmail.create!(address: "otp4@example.com", confirm_policy: true)
    otp_key = "secret_key_101"
    otp_counter = 40
    expires_at = 1.hour.from_now.to_i

    email.store_otp(otp_key, otp_counter, expires_at)
    email.update!(locked_at: Time.current)

    otp_data = email.get_otp

    assert_nil otp_data
  end

  test "get_otp returns nil when otp_private_key is blank" do
    email = UserIdentityEmail.create!(address: "otp5@example.com", confirm_policy: true)

    otp_data = email.get_otp

    assert_nil otp_data
  end

  test "otp_expired? returns true when otp_expires_at is nil" do
    email = UserIdentityEmail.create!(address: "otp6@example.com", confirm_policy: true)

    assert_predicate email, :otp_expired?
  end

  test "otp_expired? returns true when otp_expires_at is in the past" do
    email = UserIdentityEmail.create!(address: "otp7@example.com", confirm_policy: true)
    email.update!(otp_expires_at: 1.hour.ago)

    assert_predicate email, :otp_expired?
  end

  test "otp_expired? returns false when otp_expires_at is in the future" do
    email = UserIdentityEmail.create!(address: "otp8@example.com", confirm_policy: true)
    email.update!(otp_expires_at: 1.hour.from_now)

    assert_not email.otp_expired?
  end

  test "otp_active? returns true when OTP is not expired and not locked" do
    email = UserIdentityEmail.create!(address: "otp9@example.com", confirm_policy: true)
    email.update!(otp_expires_at: 1.hour.from_now, locked_at: nil)

    assert_predicate email, :otp_active?
  end

  test "otp_active? returns false when OTP is expired" do
    email = UserIdentityEmail.create!(address: "otp10@example.com", confirm_policy: true)
    email.update!(otp_expires_at: 1.hour.ago)

    assert_not email.otp_active?
  end

  test "otp_active? returns false when OTP is locked" do
    email = UserIdentityEmail.create!(address: "otp11@example.com", confirm_policy: true)
    email.update!(otp_expires_at: 1.hour.from_now, locked_at: Time.current)

    assert_not email.otp_active?
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "clear_otp clears all OTP data" do
    email = UserIdentityEmail.create!(address: "otp12@example.com", confirm_policy: true)
    email.store_otp("key", 50, 1.hour.from_now.to_i)
    email.update!(locked_at: Time.current, otp_attempts_count: 2)

    email.clear_otp

    assert_nil email.otp_private_key
    assert_nil email.otp_counter
    assert_nil email.otp_expires_at
    assert_equal 0, email.otp_attempts_count
    assert_nil email.locked_at
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "validates address with pass_code when address is nil" do
    email = UserIdentityEmail.new(address: nil, pass_code: "123456")

    assert_predicate email, :valid?
  end

  test "validates pass_code presence when pass_code is not nil" do
    email = UserIdentityEmail.new(address: nil, pass_code: nil)

    assert_not email.valid?
  end

  test "validates pass_code length exactly 6" do
    email = UserIdentityEmail.new(address: nil, pass_code: "12345")

    assert_not email.valid?

    email = UserIdentityEmail.new(address: nil, pass_code: "1234567")

    assert_not email.valid?
  end

  test "validates pass_code is integer" do
    email = UserIdentityEmail.new(address: nil, pass_code: "12345a")

    assert_not email.valid?
  end
end
