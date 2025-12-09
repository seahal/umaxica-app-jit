# frozen_string_literal: true

require "test_helper"

# Test with UserIdentityTelephone which includes Telephone
class TelephoneTest < ActiveSupport::TestCase
  test "concern can be included in a class" do
    assert_includes UserIdentityTelephone.included_modules, Telephone
  end

  test "concern adds confirm_policy accessor" do
    telephone = UserIdentityTelephone.new

    assert_respond_to telephone, :confirm_policy
    assert_respond_to telephone, :confirm_policy=
  end

  test "concern adds confirm_using_mfa accessor" do
    telephone = UserIdentityTelephone.new

    assert_respond_to telephone, :confirm_using_mfa
    assert_respond_to telephone, :confirm_using_mfa=
  end

  test "concern adds pass_code accessor" do
    telephone = UserIdentityTelephone.new

    assert_respond_to telephone, :pass_code
    assert_respond_to telephone, :pass_code=
  end

  test "encrypts number deterministically" do
    telephone1 = UserIdentityTelephone.create!(number: "+1234567890", confirm_policy: true, confirm_using_mfa: true)
    telephone2 = UserIdentityTelephone.create!(number: "+0987654321", confirm_policy: true, confirm_using_mfa: true)

    # Different numbers should have different encrypted values
    raw1 = UserIdentityTelephone.connection.execute("SELECT number FROM user_identity_telephones WHERE id = '#{telephone1.id}'").first
    raw2 = UserIdentityTelephone.connection.execute("SELECT number FROM user_identity_telephones WHERE id = '#{telephone2.id}'").first

    assert_not_equal raw1["number"], raw2["number"]
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "validates number format" do
    # Valid phone numbers
    assert_predicate UserIdentityTelephone.new(number: "+1234567890", confirm_policy: true, confirm_using_mfa: true), :valid?
    assert_predicate UserIdentityTelephone.new(number: "+81-90-1234-5678", confirm_policy: true, confirm_using_mfa: true), :valid?
    assert_predicate UserIdentityTelephone.new(number: "+1 (555) 123-4567", confirm_policy: true, confirm_using_mfa: true), :valid?

    # Invalid phone number
    assert_not UserIdentityTelephone.new(number: "invalid!@#", confirm_policy: true, confirm_using_mfa: true).valid?
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "validates number length" do
    # Too short
    assert_not UserIdentityTelephone.new(number: "12", confirm_policy: true, confirm_using_mfa: true).valid?

    # Too long
    assert_not UserIdentityTelephone.new(number: "+123456789012345678901", confirm_policy: true, confirm_using_mfa: true).valid?

    # Just right
    assert_predicate UserIdentityTelephone.new(number: "1234567890", confirm_policy: true, confirm_using_mfa: true), :valid?
  end

  test "validates uniqueness of number" do
    UserIdentityTelephone.create!(number: "+1234567890", confirm_policy: true, confirm_using_mfa: true)
    duplicate = UserIdentityTelephone.new(number: "+1234567890", confirm_policy: true, confirm_using_mfa: true)

    assert_not duplicate.valid?
    assert_predicate duplicate.errors[:number], :any?
  end

  test "increment_attempts! increases otp_attempts_count atomically" do
    telephone = UserIdentityTelephone.create!(number: "+1234567890", confirm_policy: true, confirm_using_mfa: true)
    initial_count = telephone.otp_attempts_count

    telephone.increment_attempts!

    assert_equal initial_count + 1, telephone.reload.otp_attempts_count
  end

  test "locked? returns false when attempts < 3" do
    telephone = UserIdentityTelephone.create!(number: "+1234567890", confirm_policy: true, confirm_using_mfa: true)

    assert_not telephone.locked?

    telephone.increment_attempts!

    assert_not telephone.reload.locked?

    telephone.increment_attempts!

    assert_not telephone.reload.locked?
  end

  test "locked? returns true when attempts >= 3" do
    telephone = UserIdentityTelephone.create!(number: "+1234567890", confirm_policy: true, confirm_using_mfa: true)

    3.times { telephone.increment_attempts! }

    assert_predicate telephone.reload, :locked?
  end

  test "locked? returns true when locked_at is set" do
    telephone = UserIdentityTelephone.create!(number: "+1234567890", confirm_policy: true, confirm_using_mfa: true)
    telephone.update!(locked_at: Time.current)

    assert_predicate telephone, :locked?
  end

  test "clear_otp resets attempts and locked_at" do
    telephone = UserIdentityTelephone.create!(number: "+1234567890", confirm_policy: true, confirm_using_mfa: true)
    3.times { telephone.increment_attempts! }
    telephone.update!(locked_at: Time.current)

    telephone.clear_otp

    assert_equal 0, telephone.otp_attempts_count
    assert_nil telephone.locked_at
  end
end
