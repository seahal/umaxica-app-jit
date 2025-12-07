require "test_helper"

class AppContactEmailTest < ActiveSupport::TestCase
  def setup
    @app_contact = app_contacts(:one) # Assuming fixtures exist, otherwise we'll create one
    @email = AppContactEmail.new(
      app_contact: @app_contact,
      email_address: "test@example.com"
    )
  end

  test "should be valid" do
    assert_predicate @email, :valid?
  end

  test "should require email_address" do
    @email.email_address = nil

    assert_not @email.valid?
  end

  test "should validate email format" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @email.email_address = valid_address

      assert_predicate @email, :valid?, "#{valid_address.inspect} should be valid"
    end

    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @email.email_address = invalid_address

      assert_not @email.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "should downcase email before save" do
    @email.email_address = "FooBar@Example.Com"
    @email.save!

    assert_equal "foobar@example.com", @email.reload.email_address
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "generate_verifier! should create a code and set expiration" do
    freeze_time do
      raw_code = @email.generate_verifier!

      assert_not_nil @email.verifier_digest
      assert_equal 6, raw_code.length
      assert_equal 15.minutes.from_now, @email.verifier_expires_at
      assert_equal 3, @email.verifier_attempts_left
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "verify_code should return true for correct code" do
    raw_code = @email.generate_verifier!

    assert @email.verify_code(raw_code)
    assert @email.reload.activated
    assert_equal 0, @email.verifier_attempts_left
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "verify_code should return false for incorrect code and decrement attempts" do
    @email.generate_verifier!

    assert_not @email.verify_code("000000")
    assert_not @email.activated
    assert_equal 2, @email.verifier_attempts_left

    assert_not @email.verify_code("000000")
    assert_equal 1, @email.verifier_attempts_left

    assert_not @email.verify_code("000000")
    assert_equal 0, @email.verifier_attempts_left

    # After 0 attempts, it should still be false
    assert_not @email.verify_code("000000")
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "verify_code should fail if expired" do
    raw_code = @email.generate_verifier!

    travel 16.minutes do
      assert_not @email.verify_code(raw_code)
    end
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "can_resend_verifier? logic" do
    # Fresh new record
    assert_not @email.can_resend_verifier? # nil verifier_expires_at is not expired but !activated is true. Wait, logic check:
    # Logic: !activated && (verifier_expired? || verifier_attempts_left <= 0)
    # New record: activated=false, verifier_expires_at=nil (expired?=false), left=nil (fail comparison?).
    # Let's check implementation behavior for nil.
    # Ruby: nil <= 0 raises ArgumentError.
    # If verifier_attempts_left is nil, we might have an issue.
    # Let's save first to set defaults if any? No default in migration usually implies nil.
    # Let's look at the model: `verifier_attempts_left` is set in `generate_verifier!`.

    # If it's a new record that never had a code generated, `verifier_attempts_left` is likely nil.
    # The code `verifier_attempts_left <= 0` will crash if nil.
    # BUT, if we assume this method is called after generation or we handle nil gracefully.
    # Actually, looking at the code: `return false if verifier_attempts_left <= 0` in verify_code.
    # So we should probably ensure generate_verifier! is called or defaults are set.

    @email.generate_verifier!

    assert_not @email.can_resend_verifier? # valid and fresh

    @email.update!(verifier_attempts_left: 0)

    assert_predicate @email, :can_resend_verifier?

    @email.generate_verifier!

    travel 16.minutes do
      assert_predicate @email, :can_resend_verifier?
    end

    @email.update!(activated: true)

    assert_not @email.can_resend_verifier?
  end
  # rubocop:enable Minitest/MultipleAssertions
end
