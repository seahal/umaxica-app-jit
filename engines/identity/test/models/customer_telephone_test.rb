# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_telephones
# Database name: guest
#
#  id                           :bigint           not null, primary key
#  locked_at                    :datetime         default(-Infinity), not null
#  number                       :string           default(""), not null
#  number_bidx                  :string
#  number_digest                :string
#  otp_attempts_count           :integer          default(0), not null
#  otp_counter                  :text             default(""), not null
#  otp_expires_at               :datetime         default(-Infinity), not null
#  otp_last_sent_at             :datetime         default(-Infinity), not null
#  otp_private_key              :string           default(""), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  customer_id                  :bigint           not null
#  customer_telephone_status_id :bigint           default(1), not null
#  public_id                    :string(21)       not null
#
# Indexes
#
#  index_customer_telephones_on_customer_id                   (customer_id)
#  index_customer_telephones_on_customer_telephone_status_id  (customer_telephone_status_id)
#  index_customer_telephones_on_lower_number                  (lower((number)::text)) UNIQUE
#  index_customer_telephones_on_number_bidx                   (number_bidx) UNIQUE WHERE (number_bidx IS NOT NULL)
#  index_customer_telephones_on_number_digest                 (number_digest) UNIQUE WHERE (number_digest IS NOT NULL)
#  index_customer_telephones_on_public_id                     (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (customer_telephone_status_id => customer_telephone_statuses.id)
#
require "test_helper"

class CustomerTelephoneTest < ActiveSupport::TestCase
  setup do
    CustomerTelephoneStatus::UNVERIFIED.then { |id| CustomerTelephoneStatus.find_or_create_by!(id: id) }
    @customer = Customer.create!
    @valid_attributes = {
      raw_number: "+1234567890",
      confirm_policy: true,
      confirm_using_mfa: true,
      customer: @customer,
    }.freeze
  end

  # Basic model structure
  test "should inherit from GuestRecord" do
    assert_operator CustomerTelephone, :<, GuestRecord
  end

  test "should include Telephone concern" do
    assert_includes CustomerTelephone.included_modules, Telephone
  end

  test "should include PublicId concern" do
    assert_includes CustomerTelephone.included_modules, PublicId
  end

  # Validation
  test "should be valid with valid phone number and policy confirmations" do
    telephone = CustomerTelephone.new(@valid_attributes)

    assert_predicate telephone, :valid?
  end

  test "should require valid phone number format" do
    telephone = CustomerTelephone.new(@valid_attributes.merge(raw_number: "invalid!@#"))

    assert_not telephone.valid?
    assert_predicate telephone.errors[:number], :any?
  end

  test "should require policy confirmation" do
    telephone = CustomerTelephone.new(@valid_attributes.merge(confirm_policy: false))

    assert_not telephone.valid?
    assert_predicate telephone.errors[:confirm_policy], :any?
  end

  test "should require MFA confirmation" do
    telephone = CustomerTelephone.new(@valid_attributes.merge(confirm_using_mfa: false))

    assert_not telephone.valid?
    assert_predicate telephone.errors[:confirm_using_mfa], :any?
  end

  test "to_param returns public_id" do
    telephone = CustomerTelephone.create!(@valid_attributes)

    assert_equal telephone.public_id, telephone.to_param
  end

  # Maximum limit boundary analysis (MAX = 2)
  test "MAX_TELEPHONES_PER_CUSTOMER is 2" do
    assert_equal 2, CustomerTelephone::MAX_TELEPHONES_PER_CUSTOMER
  end

  test "enforce_customer_telephone_limit: at limit is invalid" do
    Prosopite.pause do
      CustomerTelephone::MAX_TELEPHONES_PER_CUSTOMER.times do |i|
        CustomerTelephone.create!(@valid_attributes.merge(raw_number: "+1555123456#{i}"))
      end
    end

    at_limit = CustomerTelephone.new(@valid_attributes.merge(raw_number: "+15559000001"))

    assert_not at_limit.valid?
    assert_includes at_limit.errors[:base],
                    "exceeds maximum telephones per customer (#{CustomerTelephone::MAX_TELEPHONES_PER_CUSTOMER})"
  end

  test "enforce_customer_telephone_limit: one below limit is valid" do
    Prosopite.pause do
      (CustomerTelephone::MAX_TELEPHONES_PER_CUSTOMER - 1).times do |i|
        CustomerTelephone.create!(@valid_attributes.merge(raw_number: "+1555123456#{i}"))
      end
    end

    below_limit = CustomerTelephone.new(@valid_attributes.merge(raw_number: "+15559000002"))

    assert_predicate below_limit, :valid?
  end

  # number_bidx / number_digest
  test "sets number_bidx and number_digest on save" do
    telephone = CustomerTelephone.create!(@valid_attributes)
    expected = IdentifierBlindIndex.bidx_for_telephone(telephone.number)

    assert_equal expected, telephone.number_bidx
    assert_equal expected, telephone.number_digest
  end

  test "number_bidx uniqueness prevents duplicate phone numbers" do
    CustomerTelephone.create!(@valid_attributes)
    duplicate = CustomerTelephone.new(@valid_attributes.merge(customer: Customer.create!))

    assert_not duplicate.valid?
    assert_predicate duplicate.errors[:number], :any?
  end

  # locked? sentinel behavior
  test "locked? returns false when locked_at is +infinity sentinel" do
    telephone = CustomerTelephone.new(@valid_attributes)
    telephone.locked_at = Float::INFINITY

    assert_not telephone.locked?
  end

  test "locked? returns false when locked_at is -infinity sentinel" do
    telephone = CustomerTelephone.new(@valid_attributes)
    telephone.locked_at = -Float::INFINITY

    assert_not telephone.locked?
  end

  test "locked? returns true when locked_at is a past timestamp" do
    telephone = CustomerTelephone.new(@valid_attributes)
    telephone.locked_at = 1.minute.ago

    assert_predicate telephone, :locked?
  end

  test "locked? returns false when otp_attempts_count is below threshold" do
    telephone = CustomerTelephone.new(@valid_attributes)
    telephone.locked_at = -Float::INFINITY
    telephone.otp_attempts_count = 2

    assert_not telephone.locked?
  end

  test "locked? returns true when otp_attempts_count reaches threshold" do
    telephone = CustomerTelephone.new(@valid_attributes)
    telephone.locked_at = -Float::INFINITY
    telephone.otp_attempts_count = 3

    assert_predicate telephone, :locked?
  end

  # OTP cooldown behavior
  test "otp_cooldown_active? returns false when otp_last_sent_at is -infinity sentinel" do
    telephone = CustomerTelephone.create!(@valid_attributes)
    telephone.update_columns(otp_last_sent_at: "-infinity")

    assert_not telephone.reload.otp_cooldown_active?
  end

  test "otp_cooldown_active? returns true when OTP was sent within cooldown period" do
    telephone = CustomerTelephone.create!(@valid_attributes)
    telephone.update_columns(otp_last_sent_at: 5.seconds.ago)

    assert_predicate telephone.reload, :otp_cooldown_active?
  end

  test "otp_cooldown_active? returns false when OTP was sent before cooldown period" do
    telephone = CustomerTelephone.create!(@valid_attributes)
    telephone.update_columns(otp_last_sent_at: (Telephone::OTP_COOLDOWN_PERIOD + 1.second).ago)

    assert_not telephone.reload.otp_cooldown_active?
  end

  test "otp_cooldown_remaining returns positive seconds during active cooldown" do
    telephone = CustomerTelephone.create!(@valid_attributes)
    telephone.update_columns(otp_last_sent_at: 5.seconds.ago)

    assert_operator telephone.reload.otp_cooldown_remaining, :>, 0
  end

  test "otp_cooldown_remaining returns zero when cooldown is not active" do
    telephone = CustomerTelephone.create!(@valid_attributes)
    telephone.update_columns(otp_last_sent_at: "-infinity")

    assert_equal 0, telephone.reload.otp_cooldown_remaining
  end

  # increment_attempts! locks at threshold
  test "increment_attempts! increments otp_attempts_count by one" do
    telephone = CustomerTelephone.create!(@valid_attributes)

    assert_changes -> { telephone.reload.otp_attempts_count }, from: 0, to: 1 do
      telephone.increment_attempts!
    end
  end

  test "increment_attempts! locks the record when attempts reach threshold" do
    telephone = CustomerTelephone.create!(@valid_attributes)
    telephone.update_columns(otp_attempts_count: 2, locked_at: "-infinity")

    telephone.increment_attempts!

    assert_predicate telephone.reload, :locked?
    assert_not_equal(-Float::INFINITY, telephone.locked_at)
    assert_not_equal Float::INFINITY, telephone.locked_at
  end

  test "increment_attempts! does not overwrite locked_at when already locked" do
    telephone = CustomerTelephone.create!(@valid_attributes)
    original_locked_at = 1.minute.ago
    telephone.update_columns(otp_attempts_count: 3, locked_at: original_locked_at)

    telephone.increment_attempts!

    assert_in_delta original_locked_at.to_f, telephone.reload.locked_at.to_f, 1.0
  end

  # store_otp and clear_otp sentinel behavior
  test "store_otp sets locked_at to +infinity sentinel" do
    telephone = CustomerTelephone.create!(@valid_attributes)
    telephone.store_otp("TESTSECRET", "1", 5.minutes.from_now.to_i)

    assert_equal Float::INFINITY, telephone.reload.locked_at
  end

  test "store_otp updates otp_last_sent_at to current time" do
    telephone = CustomerTelephone.create!(@valid_attributes)
    before = Time.current
    telephone.store_otp("TESTSECRET", "1", 5.minutes.from_now.to_i)
    after = Time.current

    sent_at = telephone.reload.otp_last_sent_at

    assert_operator sent_at, :>=, before
    assert_operator sent_at, :<=, after
  end

  test "clear_otp sets locked_at to +infinity sentinel" do
    telephone = CustomerTelephone.create!(@valid_attributes)
    telephone.update_columns(locked_at: 1.minute.ago)

    telephone.clear_otp

    assert_equal Float::INFINITY, telephone.reload.locked_at
  end

  # Association
  test "association: belongs_to customer" do
    telephone = CustomerTelephone.create!(@valid_attributes)

    assert_equal @customer, telephone.customer
  end
end
