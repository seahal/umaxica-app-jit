# == Schema Information
#
# Table name: user_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_telephones_on_user_id  (user_id)
#
require "test_helper"

class UserTelephoneTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      number: "+1234567890",
      confirm_policy: true,
      confirm_using_mfa: true
    }
  end

  # Basic model structure tests
  test "should inherit from IdentifiersRecord" do
    assert UserTelephone < IdentifiersRecord
  end

  test "should include Telephone concern" do
    assert UserTelephone.included_modules.include?(Telephone)
  end

  test "should include SetId concern" do
    assert UserTelephone.included_modules.include?(SetId)
  end

  # Telephone concern validation tests
  test "should be valid with valid phone number and policy confirmations" do
    user_telephone = UserTelephone.new(@valid_attributes)
    assert user_telephone.valid?
  end

  test "should require valid phone number format" do
    user_telephone = UserTelephone.new(@valid_attributes.merge(number: "invalid!@#"))
    assert_not user_telephone.valid?
    assert_includes user_telephone.errors[:number], "は不正な値です"
  end

  test "should accept phone number with country code" do
    user_telephone = UserTelephone.new(@valid_attributes.merge(number: "+81-90-1234-5678"))
    assert user_telephone.valid?
  end

  test "should accept phone number with parentheses" do
    user_telephone = UserTelephone.new(@valid_attributes.merge(number: "+1 (555) 123-4567"))
    assert user_telephone.valid?
  end

  test "should reject phone number that is too short" do
    user_telephone = UserTelephone.new(@valid_attributes.merge(number: "12"))
    assert_not user_telephone.valid?
    assert user_telephone.errors[:number].any?
  end

  test "should reject phone number that is too long" do
    user_telephone = UserTelephone.new(@valid_attributes.merge(number: "+1234567890123456789012"))
    assert_not user_telephone.valid?
    assert user_telephone.errors[:number].any?
  end

  test "should require policy confirmation" do
    user_telephone = UserTelephone.new(@valid_attributes.merge(confirm_policy: false))
    assert_not user_telephone.valid?
    assert user_telephone.errors[:confirm_policy].any?
  end

  test "should require MFA confirmation" do
    user_telephone = UserTelephone.new(@valid_attributes.merge(confirm_using_mfa: false))
    assert_not user_telephone.valid?
    assert user_telephone.errors[:confirm_using_mfa].any?
  end


  # SetId concern tests
  test "should generate UUID v7 before creation" do
    user_telephone = UserTelephone.new(@valid_attributes)
    assert_nil user_telephone.id
    user_telephone.save!
    assert_not_nil user_telephone.id
    # UUID v7 format: xxxxxxxx-xxxx-7xxx-xxxx-xxxxxxxxxxxx
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i, user_telephone.id)
  end
end
