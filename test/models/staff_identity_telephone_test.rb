# == Schema Information
#
# Table name: staff_identity_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  staff_id   :bigint
#
# Indexes
#
#  index_staff_identity_telephones_on_staff_id  (staff_id)
#
require "test_helper"

class StaffIdentityTelephoneTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      number: "+1234567890",
      confirm_policy: true,
      confirm_using_mfa: true
    }.freeze
  end

  # Basic model structure tests
  test "should inherit from IdentitiesRecord" do
    assert_operator StaffIdentityTelephone, :<, IdentitiesRecord
  end

  test "should include Telephone concern" do
    assert_includes StaffIdentityTelephone.included_modules, Telephone
  end

  test "should include SetId concern" do
    assert_includes StaffIdentityTelephone.included_modules, SetId
  end

  # Telephone concern validation tests
  test "should be valid with valid phone number and policy confirmations" do
    staff_telephone = StaffIdentityTelephone.new(@valid_attributes)

    assert_predicate staff_telephone, :valid?
  end

  test "should require valid phone number format" do
    staff_telephone = StaffIdentityTelephone.new(@valid_attributes.merge(number: "invalid!@#"))

    assert_not staff_telephone.valid?
    assert_predicate staff_telephone.errors[:number], :any?
  end

  test "should accept phone number with country code" do
    staff_telephone = StaffIdentityTelephone.new(@valid_attributes.merge(number: "+81-90-1234-5678"))

    assert_predicate staff_telephone, :valid?
  end

  test "should accept phone number with parentheses" do
    staff_telephone = StaffIdentityTelephone.new(@valid_attributes.merge(number: "+1 (555) 123-4567"))

    assert_predicate staff_telephone, :valid?
  end

  test "should reject phone number that is too short" do
    staff_telephone = StaffIdentityTelephone.new(@valid_attributes.merge(number: "12"))

    assert_not staff_telephone.valid?
    assert_predicate staff_telephone.errors[:number], :any?
  end

  test "should reject phone number that is too long" do
    staff_telephone = StaffIdentityTelephone.new(@valid_attributes.merge(number: "+1234567890123456789012"))

    assert_not staff_telephone.valid?
    assert_predicate staff_telephone.errors[:number], :any?
  end

  test "should require policy confirmation" do
    staff_telephone = StaffIdentityTelephone.new(@valid_attributes.merge(confirm_policy: false))

    assert_not staff_telephone.valid?
    assert_predicate staff_telephone.errors[:confirm_policy], :any?
  end

  test "should require MFA confirmation" do
    staff_telephone = StaffIdentityTelephone.new(@valid_attributes.merge(confirm_using_mfa: false))

    assert_not staff_telephone.valid?
    assert_predicate staff_telephone.errors[:confirm_using_mfa], :any?
  end

  # SetId concern tests
  test "should generate UUID v7 before creation" do
    staff_telephone = StaffIdentityTelephone.new(@valid_attributes)

    assert_nil staff_telephone.id
    staff_telephone.save!

    assert_not_nil staff_telephone.id
    # UUID v7 format: xxxxxxxx-xxxx-7xxx-xxxx-xxxxxxxxxxxx
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i, staff_telephone.id)
  end
end
