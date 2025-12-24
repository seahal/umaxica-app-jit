# == Schema Information
#
# Table name: staff_identity_email_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

require "test_helper"

class StaffIdentityEmailStatusTest < ActiveSupport::TestCase
  test "valid status with id" do
    status = staff_identity_email_statuses(:unverified)

    assert_predicate status, :valid?
  end

  test "has many staff_identity_emails" do
    assert StaffIdentityEmailStatus.reflect_on_association(:staff_identity_emails)
  end

  test "validates presence of id" do
    status = StaffIdentityEmailStatus.new(id: nil)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates length of id" do
    status = StaffIdentityEmailStatus.new(id: "a" * 256)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    existing = staff_identity_email_statuses(:unverified)
    duplicate = StaffIdentityEmailStatus.new(id: existing.id)

    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "status constants are defined" do
    assert_equal "UNVERIFIED", StaffIdentityEmailStatus::UNVERIFIED
    assert_equal "VERIFIED", StaffIdentityEmailStatus::VERIFIED
  end

  test "additional status constants are defined" do
    assert_equal "SUSPENDED", StaffIdentityEmailStatus::SUSPENDED
    assert_equal "DELETED", StaffIdentityEmailStatus::DELETED
  end

  test "restrict_with_error prevents deletion when emails exist" do
    status = staff_identity_email_statuses(:verified)
    # Create a staff identity email with this status
    staff = Staff.create!(public_id: "test-staff-#{SecureRandom.hex(4)}")
    StaffIdentityEmail.create!(
      id: SecureRandom.uuid,
      address: "staff@example.com",
      staff_id: staff.id,
      staff_identity_email_status_id: status.id
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
