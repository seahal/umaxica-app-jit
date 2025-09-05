# == Schema Information
#
# Table name: user_emails
#
#  id         :uuid             not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_emails_on_user_id  (user_id)
#
require "test_helper"

class UserEmailTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      address: "test@example.com",
      confirm_policy: true
    }
  end

  # Basic model structure tests
  test "should inherit from IdentifiersRecord" do
    assert UserEmail < IdentifiersRecord
  end

  test "should include Email concern" do
    assert UserEmail.included_modules.include?(Email)
  end

  test "should include SetId concern" do
    assert UserEmail.included_modules.include?(SetId)
  end

  # Email concern validation tests
  test "should be valid with valid email and policy confirmation" do
    user_email = UserEmail.new(@valid_attributes)
    assert user_email.valid?
  end

  # test "should require valid email format" do
  #   user_email = UserEmail.new(@valid_attributes.merge(address: "invalid-email"))
  #   assert_not user_email.valid?
  #   assert_includes user_email.errors[:address], "is invalid"
  # end

  # test "should require email presence" do
  #   user_email = UserEmail.new(@valid_attributes.except(:address))
  #   assert_not user_email.valid?
  #   assert_includes user_email.errors[:address], "can't be blank"
  # end

  # test "should require policy confirmation" do
  #   user_email = UserEmail.new(@valid_attributes.merge(confirm_policy: false))
  #   assert_not user_email.valid?
  #   assert_includes user_email.errors[:confirm_policy], "must be accepted"
  # end

  # test "should require unique email addresses" do
  #   UserEmail.create!(@valid_attributes)
  #   duplicate_email = UserEmail.new(@valid_attributes)
  #   assert_not duplicate_email.valid?
  #   assert_includes duplicate_email.errors[:address], "has already been taken"
  # end

  test "should downcase email address before saving" do
    user_email = UserEmail.new(@valid_attributes.merge(address: "TEST@EXAMPLE.COM"))
    user_email.save!
    assert_equal "test@example.com", user_email.address
  end

  # Pass code validation tests
  test "should be valid with pass_code instead of email" do
    user_email = UserEmail.new(pass_code: "123456")
    assert user_email.valid?
  end

  # test "should require 6-digit numeric pass_code" do
  #   user_email = UserEmail.new(pass_code: "12345")
  #   assert_not user_email.valid?
  #   assert_includes user_email.errors[:pass_code], "is the wrong length (should be 6 characters)"
  # end

  # test "should require numeric pass_code" do
  #   user_email = UserEmail.new(pass_code: "abcdef")
  #   assert_not user_email.valid?
  #   assert_includes user_email.errors[:pass_code], "is not a number"
  # end

  test "should not require email when pass_code is present" do
    user_email = UserEmail.new(pass_code: "123456")
    assert user_email.valid?
    assert_not user_email.errors[:address].any?
    assert_not user_email.errors[:confirm_policy].any?
  end

  # SetId concern tests
  # test "should generate UUID v7 before creation" do
  #   user_email = UserEmail.new(@valid_attributes)
  #   assert_nil user_email.id
  #   user_email.save!
  #   assert_not_nil user_email.id
  #   assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i, user_email.id)
  # end

  # test "should not override manually set id" do
  #   custom_id = SecureRandom.uuid_v7
  #   user_email = UserEmail.new(@valid_attributes.merge(id: custom_id))
  #   user_email.save!
  #   assert_equal custom_id, user_email.id
  # end

  # Encryption tests
  test "should encrypt email address" do
    user_email = UserEmail.create!(@valid_attributes)
    # The address should be encrypted in the database
    raw_data = UserEmail.connection.execute("SELECT address FROM user_emails WHERE id = '#{user_email.id}'").first
    assert_not_equal @valid_attributes[:address], raw_data["address"] if raw_data
  end

  # Edge case tests
  test "should handle nil address gracefully when pass_code is set" do
    user_email = UserEmail.new(address: nil, pass_code: "123456")
    assert user_email.valid?
  end

  # test "should reject both nil address and nil pass_code" do
  #   user_email = UserEmail.new(address: nil, pass_code: nil)
  #   assert_not user_email.valid?
  #   assert_includes user_email.errors[:address], "can't be blank"
  # end
end
