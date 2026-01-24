# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_email_statuses
# Database name: operator
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#
# Indexes
#
#  index_staff_identity_email_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

require "test_helper"

class StaffEmailStatusTest < ActiveSupport::TestCase
  fixtures :staff_email_statuses

  test "valid status with id" do
    status = StaffEmailStatus.find("UNVERIFIED")

    assert_predicate status, :valid?
  end

  test "has many staff_emails" do
    assert StaffEmailStatus.reflect_on_association(:staff_emails)
  end

  test "validates presence of id" do
    status = StaffEmailStatus.new(id: nil)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates length of id" do
    status = StaffEmailStatus.new(id: "a" * 256)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    existing = StaffEmailStatus.find("UNVERIFIED")
    duplicate = StaffEmailStatus.new(id: existing.id)

    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "status constants are defined" do
    assert_equal "UNVERIFIED", StaffEmailStatus::UNVERIFIED
    assert_equal "VERIFIED", StaffEmailStatus::VERIFIED
  end

  test "additional status constants are defined" do
    assert_equal "SUSPENDED", StaffEmailStatus::SUSPENDED
    assert_equal "DELETED", StaffEmailStatus::DELETED
  end

  test "restrict_with_error prevents deletion when emails exist" do
    status = StaffEmailStatus.find("VERIFIED")
    # Create a staff identity email with this status
    staff = Staff.create!
    StaffEmail.create!(
      id: SecureRandom.uuid,
      address: "staff@example.com",
      staff_id: staff.id,
      staff_email_status_id: status.id,
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
