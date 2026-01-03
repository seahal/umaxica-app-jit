# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_emails
#
#  id                     :string           not null, primary key
#  app_contact_id         :uuid             not null
#  email_address          :string(1000)     default(""), not null
#  activated              :boolean          default(FALSE), not null
#  deletable              :boolean          default(FALSE), not null
#  remaining_views        :integer          default(0), not null
#  verifier_digest        :string(255)      default(""), not null
#  verifier_expires_at    :timestamptz      default("-infinity"), not null
#  verifier_attempts_left :integer          default(0), not null
#  token_digest           :string(255)      default(""), not null
#  token_expires_at       :timestamptz      default("-infinity"), not null
#  token_viewed           :boolean          default(FALSE), not null
#  expires_at             :timestamptz      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_app_contact_emails_on_app_contact_id       (app_contact_id)
#  index_app_contact_emails_on_email_address        (email_address)
#  index_app_contact_emails_on_expires_at           (expires_at)
#  index_app_contact_emails_on_verifier_expires_at  (verifier_expires_at)
#

require "test_helper"

class AppContactEmailTest < ActiveSupport::TestCase
  setup do
    # Seed necessary reference data for tests
    %w(APPLICATION_INQUIRY NEYO).each do |id|
      AppContactCategory.create_with(created_at: Time.current, updated_at: Time.current).find_or_create_by(id: id)
    end
    %w(NEYO SET_UP CHECKED_EMAIL_ADDRESS CHECKED_TELEPHONE_NUMBER COMPLETED_CONTACT_ACTION).each do |id|
      AppContactStatus.find_or_create_by(id: id)
    end

    @app_contact = AppContact.create!(
      public_id: "test_contact_1",
      confirm_policy: "1",
    )

    @email = AppContactEmail.new(
      app_contact: @app_contact,
      email_address: "test@example.com",
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
    valid_addresses = %w(user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn)
    valid_addresses.each do |valid_address|
      @email.email_address = valid_address

      assert_predicate @email, :valid?, "#{valid_address.inspect} should be valid"
    end

    invalid_addresses = %w(user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com)
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

  test "verifier_expired? returns true when verifier has expired" do
    @email.generate_verifier!

    travel 16.minutes do
      assert_predicate @email, :verifier_expired?
    end
  end

  test "verifier_expired? returns false when verifier has not expired" do
    @email.generate_verifier!

    travel 10.minutes do
      assert_not @email.verifier_expired?
    end
  end

  test "can_resend_verifier? returns true when not activated and expired" do
    @email.generate_verifier!

    travel 16.minutes do
      assert_predicate @email, :can_resend_verifier?
    end
  end

  test "can_resend_verifier? returns true when not activated and no attempts left" do
    @email.generate_verifier!
    @email.update!(verifier_attempts_left: 0)

    assert_predicate @email, :can_resend_verifier?
  end

  test "can_resend_verifier? returns false when already activated" do
    @email.generate_verifier!
    @email.update!(activated: true)

    assert_not @email.can_resend_verifier?
  end

  test "can_resend_verifier? returns false when not activated but still has attempts and not expired" do
    @email.generate_verifier!

    assert_not @email.can_resend_verifier?
  end
end
