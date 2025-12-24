require "test_helper"

class TelephoneConcernTest < ActiveSupport::TestCase
  setup do
    @telephone = StaffIdentityTelephone.new(
      number: "+1234567890",
      staff: staffs(:none_staff)
    )
    @telephone.save!(validate: false)
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "store_otp updates otp fields" do
    expires_at = 5.minutes.from_now.to_i
    @telephone.store_otp("secret", 123, expires_at)

    assert_equal "secret", @telephone.otp_private_key
    assert_equal "123", @telephone.otp_counter
    assert_equal Time.zone.at(expires_at), @telephone.otp_expires_at
    assert_equal 0, @telephone.otp_attempts_count
    # unlocked sentinel
    locked = @telephone.locked_at
    assert locked.nil? || locked.to_s == "-infinity" || (locked.is_a?(Float) && locked == -Float::INFINITY)
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "get_otp returns otp details if valid" do
    expires_at = 5.minutes.from_now.to_i
    @telephone.store_otp("secret", 123, expires_at)

    otp = @telephone.get_otp

    assert_equal "secret", otp[:otp_private_key]
    assert_equal 123, otp[:otp_counter]
    assert_equal expires_at, otp[:otp_expires_at]
  end

  test "get_otp returns nil if otp_private_key is blank" do
    @telephone.otp_private_key = ""
    @telephone.save!(validate: false) # Use empty string as DB requires not null

    assert_nil @telephone.get_otp
  end

  test "get_otp returns nil if otp expired" do
    @telephone.store_otp("secret", 123, 5.minutes.ago.to_i)

    assert_nil @telephone.get_otp
  end

  test "get_otp returns nil if locked" do
    @telephone.store_otp("secret", 123, 5.minutes.from_now.to_i)
    @telephone.update!(locked_at: Time.current)

    assert_nil @telephone.get_otp
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "clear_otp clears otp fields" do
    @telephone.store_otp("secret", 123, 5.minutes.from_now.to_i)
    @telephone.clear_otp

    assert_equal "secret", @telephone.otp_private_key # Persists
    assert_equal "0", @telephone.otp_counter
    # Expect -infinity logic
    expires = @telephone.otp_expires_at
    assert expires.nil? || expires.to_s == "-infinity" || (expires.is_a?(Float) && expires == -Float::INFINITY)

    assert_equal 0, @telephone.otp_attempts_count

    locked = @telephone.locked_at
    assert locked.nil? || locked.to_s == "-infinity" || (locked.is_a?(Float) && locked == -Float::INFINITY)
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "otp_expired? returns true if expired or nil" do
    @telephone.update!(otp_expires_at: "-infinity") # Use sentinel

    assert_predicate @telephone, :otp_expired?

    @telephone.update!(otp_expires_at: 5.minutes.ago)

    assert_predicate @telephone, :otp_expired?

    @telephone.update!(otp_expires_at: 5.minutes.from_now)

    assert_not @telephone.otp_expired?
  end

  test "otp_active? returns true if not expired and not locked" do
    @telephone.store_otp("secret", 123, 5.minutes.from_now.to_i)

    assert_predicate @telephone, :otp_active?

    @telephone.update!(locked_at: Time.current)

    assert_not @telephone.otp_active?

    @telephone.update!(locked_at: "-infinity", otp_expires_at: 5.minutes.ago)

    assert_not @telephone.otp_active?
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "locked? returns true if locked_at present or attempts exceeded" do
    assert_not @telephone.locked?

    @telephone.update!(locked_at: Time.current)

    assert_predicate @telephone, :locked?

    @telephone.update!(locked_at: "-infinity", otp_attempts_count: 3)

    assert_predicate @telephone, :locked?
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "increment_attempts! increments counter and locks if threshold reached" do
    @telephone.store_otp("secret", 123, 5.minutes.from_now.to_i)

    @telephone.increment_attempts!

    assert_equal 1, @telephone.otp_attempts_count
    assert_not @telephone.locked?

    @telephone.increment_attempts!

    assert_equal 2, @telephone.otp_attempts_count
    assert_not @telephone.locked?

    @telephone.increment_attempts!

    assert_equal 3, @telephone.otp_attempts_count
    assert_predicate @telephone, :locked?
    assert_not_nil @telephone.locked_at
  end
  # rubocop:enable Minitest/MultipleAssertions
end
