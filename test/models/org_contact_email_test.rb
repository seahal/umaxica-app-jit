require "test_helper"

class OrgContactEmailTest < ActiveSupport::TestCase
  def setup
    @org_contact = org_contacts(:one)
    @email = OrgContactEmail.new(
      org_contact: @org_contact,
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
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp]
    valid_addresses.each do |valid_address|
      @email.email_address = valid_address

      assert_predicate @email, :valid?, "#{valid_address.inspect} should be valid"
    end

    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.]
    invalid_addresses.each do |invalid_address|
      @email.email_address = invalid_address

      assert_not @email.valid?, "#{invalid_address.inspect} should be invalid"
    end
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

  test "verify_code should return false for incorrect code" do
    @email.generate_verifier!

    assert_not @email.verify_code("000000")
    assert_not @email.activated
  end

  test "can_resend_verifier? logic" do
    assert_not @email.can_resend_verifier? # Fresh record
    @email.generate_verifier!
    # Still valid attempt window
    assert_not @email.can_resend_verifier?

    travel 16.minutes do
      assert_predicate @email, :can_resend_verifier?
    end
  end
end
