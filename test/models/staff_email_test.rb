# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_emails
#
#  id                             :uuid             not null, primary key
#  address                        :string           default(""), not null
#  created_at                     :datetime         not null
#  locked_at                      :datetime         default("-infinity"), not null
#  otp_attempts_count             :integer          default(0), not null
#  otp_counter                    :text             default(""), not null
#  otp_expires_at                 :datetime         default("-infinity"), not null
#  otp_last_sent_at               :datetime         default("-infinity"), not null
#  otp_private_key                :string           default(""), not null
#  staff_id                       :uuid             not null
#  staff_email_status_id :string(255)      default("UNVERIFIED"), not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_staff_emails_on_otp_last_sent_at                (otp_last_sent_at)
#  index_staff_emails_on_staff_id                        (staff_id)
#  index_staff_emails_on_staff_email_status_id  (staff_email_status_id)
#

require "test_helper"

class StaffEmailTest < ActiveSupport::TestCase
  setup do
    @staff = Staff.find_by!(public_id: "none_staff_id")
    @valid_attributes = {
      address: "staff@example.com",
      confirm_policy: true,
      staff: @staff,
    }.freeze
  end

  # Basic model structure tests
  test "should inherit from PrincipalRecord" do
    assert_operator StaffEmail, :<, OperatorRecord
  end

  test "should include Email concern" do
    assert_includes StaffEmail.included_modules, Email
  end

  test "should include SetId concern" do
    assert_includes StaffEmail.included_modules, SetId
  end

  # Email concern validation tests
  test "should be valid with valid email and policy confirmation" do
    staff_email = StaffEmail.new(@valid_attributes)

    assert_predicate staff_email, :valid?
  end

  test "should require valid email format" do
    staff_email = StaffEmail.new(@valid_attributes.merge(address: "invalid-email"))

    assert_not staff_email.valid?
    assert_predicate staff_email.errors[:address], :any?
  end

  test "should require email presence" do
    staff_email = StaffEmail.new(@valid_attributes.except(:address))

    assert_not staff_email.valid?
    assert_predicate staff_email.errors[:address], :any?
  end

  test "should require policy confirmation" do
    staff_email = StaffEmail.new(@valid_attributes.merge(confirm_policy: false))

    assert_not staff_email.valid?
    assert_predicate staff_email.errors[:confirm_policy], :any?
  end

  test "should require unique email addresses" do
    StaffEmail.create!(@valid_attributes)
    duplicate_email = StaffEmail.new(@valid_attributes)

    assert_not duplicate_email.valid?
    assert_predicate duplicate_email.errors[:address], :any?
  end

  test "should downcase email address before saving" do
    staff_email = StaffEmail.new(@valid_attributes.merge(address: "STAFF@EXAMPLE.COM"))
    staff_email.save!

    assert_equal "staff@example.com", staff_email.address
  end

  # SetId concern tests
  test "should generate UUID v7 before creation" do
    staff_email = StaffEmail.new(@valid_attributes)

    assert_nil staff_email.id
    staff_email.save!

    assert_not_nil staff_email.id
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i, staff_email.id)
  end

  # Encryption tests
  test "should encrypt email address" do
    staff_email = StaffEmail.create!(@valid_attributes)
    # The address should be encrypted in the database
    query = "SELECT address FROM #{StaffEmail.table_name} WHERE id = '#{staff_email.id}'"
    raw_data = StaffEmail.connection.execute(query).first
    assert_not_equal @valid_attributes[:address], raw_data["address"] if raw_data
  end

  test "enforces maximum emails per staff" do
    staff = Staff.create!(staff_status: StaffStatus.find("NEYO"))
    StaffEmail::MAX_EMAILS_PER_STAFF.times do |i|
      StaffEmail.create!(
        address: "staff_limit#{i}@example.com",
        confirm_policy: true,
        staff: staff,
      )
    end

    extra_email = StaffEmail.new(
      address: "overflow_staff@example.com",
      confirm_policy: true,
      staff: staff,
    )

    assert_not extra_email.valid?
    assert_includes extra_email.errors[:base], "exceeds maximum emails per staff (#{StaffEmail::MAX_EMAILS_PER_STAFF})"
  end
end
