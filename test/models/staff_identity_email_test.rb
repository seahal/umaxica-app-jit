# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_emails
#
#  id         :uuid             not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  staff_id   :bigint
#
# Indexes
#
#  index_staff_identity_emails_on_staff_id  (staff_id)
#
require "test_helper"

class StaffIdentityEmailTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      address: "staff@example.com",
      confirm_policy: true
    }.freeze
  end

  # Basic model structure tests
  test "should inherit from IdentitiesRecord" do
    assert_operator StaffIdentityEmail, :<, IdentitiesRecord
  end

  test "should include Email concern" do
    assert_includes StaffIdentityEmail.included_modules, Email
  end

  test "should include SetId concern" do
    assert_includes StaffIdentityEmail.included_modules, SetId
  end

  # Email concern validation tests
  test "should be valid with valid email and policy confirmation" do
    staff_email = StaffIdentityEmail.new(@valid_attributes)

    assert_predicate staff_email, :valid?
  end

  test "should require valid email format" do
    staff_email = StaffIdentityEmail.new(@valid_attributes.merge(address: "invalid-email"))

    assert_not staff_email.valid?
    assert_predicate staff_email.errors[:address], :any?
  end

  test "should require email presence" do
    staff_email = StaffIdentityEmail.new(@valid_attributes.except(:address))

    assert_not staff_email.valid?
    assert_predicate staff_email.errors[:address], :any?
  end

  test "should require policy confirmation" do
    staff_email = StaffIdentityEmail.new(@valid_attributes.merge(confirm_policy: false))

    assert_not staff_email.valid?
    assert_predicate staff_email.errors[:confirm_policy], :any?
  end

  test "should require unique email addresses" do
    StaffIdentityEmail.create!(@valid_attributes)
    duplicate_email = StaffIdentityEmail.new(@valid_attributes)

    assert_not duplicate_email.valid?
    assert_predicate duplicate_email.errors[:address], :any?
  end

  test "should downcase email address before saving" do
    staff_email = StaffIdentityEmail.new(@valid_attributes.merge(address: "STAFF@EXAMPLE.COM"))
    staff_email.save!

    assert_equal "staff@example.com", staff_email.address
  end

  # SetId concern tests
  test "should generate UUID v7 before creation" do
    staff_email = StaffIdentityEmail.new(@valid_attributes)

    assert_nil staff_email.id
    staff_email.save!

    assert_not_nil staff_email.id
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i, staff_email.id)
  end

  # Encryption tests
  test "should encrypt email address" do
    staff_email = StaffIdentityEmail.create!(@valid_attributes)
    # The address should be encrypted in the database
    raw_data = StaffIdentityEmail.connection.execute("SELECT address FROM staff_identity_emails WHERE id = '#{staff_email.id}'").first
    assert_not_equal @valid_attributes[:address], raw_data["address"] if raw_data
  end

  test "enforces maximum emails per staff" do
    staff = Staff.create!(staff_identity_status: staff_identity_statuses(:none))
    StaffIdentityEmail::MAX_EMAILS_PER_STAFF.times do |i|
      StaffIdentityEmail.create!(
        address: "staff_limit#{i}@example.com",
        confirm_policy: true,
        staff: staff
      )
    end

    extra_email = StaffIdentityEmail.new(
      address: "overflow_staff@example.com",
      confirm_policy: true,
      staff: staff
    )

    assert_not extra_email.valid?
    assert_includes extra_email.errors[:base], "exceeds maximum emails per staff (#{StaffIdentityEmail::MAX_EMAILS_PER_STAFF})"
  end
end
