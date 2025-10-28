# == Schema Information
#
# Table name: staff_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  staff_id   :bigint
#
# Indexes
#
#  index_staff_telephones_on_staff_id  (staff_id)
#
require "test_helper"

class StaffTelephoneTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      number: "+1234567890",
      confirm_policy: true,
      confirm_using_mfa: true
    }
  end

  # Basic model structure tests
  test "should inherit from IdentifiersRecord" do
    assert StaffTelephone < IdentifiersRecord
  end

  test "should include Telephone concern" do
    assert StaffTelephone.included_modules.include?(Telephone)
  end

  test "should include SetId concern" do
    assert StaffTelephone.included_modules.include?(SetId)
  end

  # Telephone concern validation tests
  test "should be valid with valid phone number and policy confirmations" do
    staff_telephone = StaffTelephone.new(@valid_attributes)
    assert staff_telephone.valid?
  end

  test "should require valid phone number format" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(number: "invalid!@#"))
    assert_not staff_telephone.valid?
    assert staff_telephone.errors[:number].any?
  end

  test "should accept phone number with country code" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(number: "+81-90-1234-5678"))
    assert staff_telephone.valid?
  end

  test "should accept phone number with parentheses" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(number: "+1 (555) 123-4567"))
    assert staff_telephone.valid?
  end

  test "should reject phone number that is too short" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(number: "12"))
    assert_not staff_telephone.valid?
    assert staff_telephone.errors[:number].any?
  end

  test "should reject phone number that is too long" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(number: "+1234567890123456789012"))
    assert_not staff_telephone.valid?
    assert staff_telephone.errors[:number].any?
  end

  test "should require policy confirmation" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(confirm_policy: false))
    assert_not staff_telephone.valid?
    assert staff_telephone.errors[:confirm_policy].any?
  end

  test "should require MFA confirmation" do
    staff_telephone = StaffTelephone.new(@valid_attributes.merge(confirm_using_mfa: false))
    assert_not staff_telephone.valid?
    assert staff_telephone.errors[:confirm_using_mfa].any?
  end

  test "should require unique phone numbers" do
    StaffTelephone.create!(@valid_attributes)
    duplicate_telephone = StaffTelephone.new(@valid_attributes)
    assert_not duplicate_telephone.valid?
    assert duplicate_telephone.errors[:number].any?
  end

  # SetId concern tests
  test "should generate UUID v7 before creation" do
    staff_telephone = StaffTelephone.new(@valid_attributes)
    assert_nil staff_telephone.id
    staff_telephone.save!
    assert_not_nil staff_telephone.id
    # UUID v7 format: xxxxxxxx-xxxx-7xxx-xxxx-xxxxxxxxxxxx
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i, staff_telephone.id)
  end

  # Encryption tests
  test "should encrypt phone number" do
    staff_telephone = StaffTelephone.create!(@valid_attributes)
    # The number should be encrypted in the database
    raw_data = StaffTelephone.connection.execute("SELECT number FROM staff_telephones WHERE id = '#{staff_telephone.id}'").first
    assert_not_equal @valid_attributes[:number], raw_data["number"] if raw_data
  end
end
