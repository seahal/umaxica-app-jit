# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_telephones
# Database name: operator
#
#  id                                 :bigint           not null, primary key
#  locked_at                          :datetime         default(-Infinity), not null
#  number                             :string           default(""), not null
#  number_bidx                        :string
#  number_digest                      :string
#  otp_attempts_count                 :integer          default(0), not null
#  otp_counter                        :text             not null
#  otp_expires_at                     :datetime         default(-Infinity), not null
#  otp_last_sent_at                   :datetime         default(-Infinity), not null
#  otp_private_key                    :string           not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  public_id                          :string(21)       not null
#  staff_id                           :bigint           not null
#  staff_identity_telephone_status_id :bigint           default(6), not null
#
# Indexes
#
#  index_staff_telephones_on_lower_number                        (lower((number)::text)) UNIQUE
#  index_staff_telephones_on_number_bidx                         (number_bidx) UNIQUE WHERE (number_bidx IS NOT NULL)
#  index_staff_telephones_on_number_digest                       (number_digest) UNIQUE WHERE (number_digest IS NOT NULL)
#  index_staff_telephones_on_public_id                           (public_id) UNIQUE
#  index_staff_telephones_on_staff_id                            (staff_id)
#  index_staff_telephones_on_staff_identity_telephone_status_id  (staff_identity_telephone_status_id)
#
# Foreign Keys
#
#  fk_rails_...  (staff_id => staffs.id)
#  fk_rails_...  (staff_identity_telephone_status_id => staff_telephone_statuses.id)
#
require "test_helper"

class StaffTelephoneTest < ActiveSupport::TestCase
  fixtures :staffs, :staff_statuses, :staff_telephone_statuses

  setup do
    @staff = staffs(:none_staff)
    @valid_attributes = {
      raw_number: "+1234567890",
      confirm_policy: true,
      confirm_using_mfa: true,
      staff: @staff,
    }.freeze
  end

  # Basic model structure
  test "should inherit from OperatorRecord" do
    assert_operator StaffTelephone, :<, OperatorRecord
  end

  test "should include Telephone concern" do
    assert_includes StaffTelephone.included_modules, Telephone
  end

  test "should include PublicId concern" do
    assert_includes StaffTelephone.included_modules, PublicId
  end

  # Validation tests
  test "should be valid with valid phone number and policy confirmations" do
    staff_telephone = StaffTelephone.new(@valid_attributes)

    assert_predicate staff_telephone, :valid?
  end

  test "should require valid phone number format" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(raw_number: "invalid!@#"))

    assert_not staff_telephone.valid?
    assert_predicate staff_telephone.errors[:number], :any?
  end

  test "should accept phone number with country code" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(raw_number: "+81-90-1234-5678"))

    assert_predicate staff_telephone, :valid?
  end

  test "should reject phone number that is too short" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(raw_number: "12"))

    assert_not staff_telephone.valid?
    assert_predicate staff_telephone.errors[:number], :any?
  end

  test "should require policy confirmation" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(confirm_policy: false))

    assert_not staff_telephone.valid?
    assert_predicate staff_telephone.errors[:confirm_policy], :any?
  end

  test "should require MFA confirmation" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(confirm_using_mfa: false))

    assert_not staff_telephone.valid?
    assert_predicate staff_telephone.errors[:confirm_using_mfa], :any?
  end

  test "to_param returns public_id" do
    staff_telephone = StaffTelephone.create!(@valid_attributes)

    assert_equal staff_telephone.public_id, staff_telephone.to_param
  end

  # Maximum limit boundary analysis
  test "enforces maximum telephones per staff: at limit is invalid" do
    staff = Staff.create!(staff_status: StaffStatus.find(StaffStatus::NOTHING))
    Prosopite.pause do
      StaffTelephone::MAX_TELEPHONES_PER_STAFF.times do |i|
        StaffTelephone.create!(
          raw_number: "+1234567890#{i}",
          confirm_policy: true,
          confirm_using_mfa: true,
          staff: staff,
        )
      end
    end

    extra_telephone = StaffTelephone.new(
      raw_number: "+19876543210",
      confirm_policy: true,
      confirm_using_mfa: true,
      staff: staff,
    )

    assert_not extra_telephone.valid?
    assert_includes extra_telephone.errors[:base],
                    "exceeds maximum telephones per staff (#{StaffTelephone::MAX_TELEPHONES_PER_STAFF})"
  end

  test "enforces maximum telephones per staff: one below limit is valid" do
    staff = Staff.create!(staff_status: StaffStatus.find(StaffStatus::NOTHING))
    Prosopite.pause do
      (StaffTelephone::MAX_TELEPHONES_PER_STAFF - 1).times do |i|
        StaffTelephone.create!(
          raw_number: "+1234567890#{i}",
          confirm_policy: true,
          confirm_using_mfa: true,
          staff: staff,
        )
      end
    end

    below_limit = StaffTelephone.new(
      raw_number: "+19876543210",
      confirm_policy: true,
      confirm_using_mfa: true,
      staff: staff,
    )

    assert_predicate below_limit, :valid?
  end

  # number_bidx / number_digest lookup
  test "sets number_bidx and number_digest on save" do
    telephone = StaffTelephone.create!(@valid_attributes)
    expected = IdentifierBlindIndex.bidx_for_telephone(telephone.number)

    assert_equal expected, telephone.number_bidx
    assert_equal expected, telephone.number_digest
  end

  test "can look up record by number_bidx without decrypting all rows" do
    telephone = StaffTelephone.create!(@valid_attributes)
    digest = IdentifierBlindIndex.bidx_for_telephone(telephone.number)

    found = @staff.staff_telephones.find_by(number_bidx: digest)

    assert_equal telephone.id, found.id
  end

  test "number_bidx uniqueness prevents duplicate phone numbers via digest" do
    StaffTelephone.create!(@valid_attributes)
    duplicate = StaffTelephone.new(@valid_attributes.merge(staff: Staff.create!(staff_status: StaffStatus.find(StaffStatus::NOTHING))))

    assert_not duplicate.valid?
    assert_predicate duplicate.errors[:number], :any?
  end

  # locked? sentinel behavior
  test "locked? returns false when locked_at is +infinity sentinel" do
    telephone = StaffTelephone.new(@valid_attributes)
    telephone.locked_at = Float::INFINITY

    assert_not telephone.locked?
  end

  test "locked? returns false when locked_at is -infinity sentinel" do
    telephone = StaffTelephone.new(@valid_attributes)
    telephone.locked_at = -Float::INFINITY

    assert_not telephone.locked?
  end

  test "locked? returns true when locked_at is a past timestamp" do
    telephone = StaffTelephone.new(@valid_attributes)
    telephone.locked_at = 1.minute.ago

    assert_predicate telephone, :locked?
  end

  test "locked? returns true when otp_attempts_count reaches threshold" do
    telephone = StaffTelephone.new(@valid_attributes)
    telephone.locked_at = -Float::INFINITY
    telephone.otp_attempts_count = 3

    assert_predicate telephone, :locked?
  end

  test "locked? returns false when otp_attempts_count is below threshold" do
    telephone = StaffTelephone.new(@valid_attributes)
    telephone.locked_at = -Float::INFINITY
    telephone.otp_attempts_count = 2

    assert_not telephone.locked?
  end

  # OTP cooldown behavior
  test "otp_cooldown_active? returns false when otp_last_sent_at is -infinity sentinel" do
    telephone = StaffTelephone.create!(@valid_attributes)
    telephone.update_columns(otp_last_sent_at: "-infinity")

    assert_not telephone.reload.otp_cooldown_active?
  end

  test "otp_cooldown_active? returns true when OTP was sent within cooldown period" do
    telephone = StaffTelephone.create!(@valid_attributes)
    telephone.update_columns(otp_last_sent_at: 5.seconds.ago)

    assert_predicate telephone.reload, :otp_cooldown_active?
  end

  test "otp_cooldown_active? returns false when OTP was sent before cooldown period" do
    telephone = StaffTelephone.create!(@valid_attributes)
    telephone.update_columns(otp_last_sent_at: (Telephone::OTP_COOLDOWN_PERIOD + 1.second).ago)

    assert_not telephone.reload.otp_cooldown_active?
  end

  # increment_attempts! locks at threshold
  test "increment_attempts! increments otp_attempts_count by one" do
    telephone = StaffTelephone.create!(@valid_attributes)

    assert_changes -> { telephone.reload.otp_attempts_count }, from: 0, to: 1 do
      telephone.increment_attempts!
    end
  end

  test "increment_attempts! locks the record at threshold" do
    telephone = StaffTelephone.create!(@valid_attributes)
    telephone.update_columns(otp_attempts_count: 2, locked_at: "-infinity")

    telephone.increment_attempts!

    assert_predicate telephone.reload, :locked?
    assert_not_equal(-Float::INFINITY, telephone.locked_at)
    assert_not_equal Float::INFINITY, telephone.locked_at
  end

  test "increment_attempts! does not overwrite locked_at when already locked" do
    telephone = StaffTelephone.create!(@valid_attributes)
    original_locked_at = 1.minute.ago
    telephone.update_columns(otp_attempts_count: 3, locked_at: original_locked_at)

    telephone.increment_attempts!

    assert_in_delta original_locked_at.to_f, telephone.reload.locked_at.to_f, 1.0
  end

  # store_otp and clear_otp sentinel behavior
  test "store_otp sets locked_at to +infinity sentinel" do
    telephone = StaffTelephone.create!(@valid_attributes)
    telephone.store_otp("TESTSECRET", "1", 5.minutes.from_now.to_i)

    assert_equal Float::INFINITY, telephone.reload.locked_at
  end

  test "store_otp updates otp_last_sent_at to current time" do
    telephone = StaffTelephone.create!(@valid_attributes)
    before = Time.current
    telephone.store_otp("TESTSECRET", "1", 5.minutes.from_now.to_i)
    after = Time.current

    sent_at = telephone.reload.otp_last_sent_at

    assert_operator sent_at, :>=, before
    assert_operator sent_at, :<=, after
  end

  test "clear_otp sets locked_at to +infinity sentinel" do
    telephone = StaffTelephone.create!(@valid_attributes)
    telephone.update_columns(locked_at: 1.minute.ago)

    telephone.clear_otp

    assert_equal Float::INFINITY, telephone.reload.locked_at
  end
end
