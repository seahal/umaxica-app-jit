# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_telephone_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

require "test_helper"

class StaffTelephoneStatusTest < ActiveSupport::TestCase
  test "valid status with id" do
    status = StaffTelephoneStatus.find("UNVERIFIED")

    assert_predicate status, :valid?
  end

  test "has many staff_telephones" do
    assert StaffTelephoneStatus.reflect_on_association(:staff_telephones)
  end

  test "validates presence of id" do
    status = StaffTelephoneStatus.new(id: nil)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates length of id" do
    status = StaffTelephoneStatus.new(id: "a" * 256)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    existing = staff_telephone_statuses(:unverified)
    duplicate = StaffTelephoneStatus.new(id: existing.id)

    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "status constants are defined" do
    assert_equal "UNVERIFIED", StaffTelephoneStatus::UNVERIFIED
    assert_equal "VERIFIED", StaffTelephoneStatus::VERIFIED
  end

  test "additional status constants are defined" do
    assert_equal "SUSPENDED", StaffTelephoneStatus::SUSPENDED
    assert_equal "DELETED", StaffTelephoneStatus::DELETED
  end

  test "restrict_with_error prevents deletion when telephones exist" do
    status = StaffTelephoneStatus.find("VERIFIED")
    # Create a staff identity telephone with this status
    staff = Staff.create!(public_id: "test-staff-#{SecureRandom.hex(4)}")
    StaffTelephone.create!(
      id: SecureRandom.uuid,
      number: "+81901234567",
      staff_id: staff.id,
      staff_telephone_status_id: status.id,
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
