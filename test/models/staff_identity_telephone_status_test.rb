# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_telephone_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

require "test_helper"

class StaffIdentityTelephoneStatusTest < ActiveSupport::TestCase
  test "valid status with id" do
    status = StaffIdentityTelephoneStatus.find("UNVERIFIED")

    assert_predicate status, :valid?
  end

  test "has many staff_identity_telephones" do
    assert StaffIdentityTelephoneStatus.reflect_on_association(:staff_identity_telephones)
  end

  test "validates presence of id" do
    status = StaffIdentityTelephoneStatus.new(id: nil)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates length of id" do
    status = StaffIdentityTelephoneStatus.new(id: "a" * 256)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    existing = staff_identity_telephone_statuses(:unverified)
    duplicate = StaffIdentityTelephoneStatus.new(id: existing.id)

    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "status constants are defined" do
    assert_equal "UNVERIFIED", StaffIdentityTelephoneStatus::UNVERIFIED
    assert_equal "VERIFIED", StaffIdentityTelephoneStatus::VERIFIED
  end

  test "additional status constants are defined" do
    assert_equal "SUSPENDED", StaffIdentityTelephoneStatus::SUSPENDED
    assert_equal "DELETED", StaffIdentityTelephoneStatus::DELETED
  end

  test "restrict_with_error prevents deletion when telephones exist" do
    status = StaffIdentityTelephoneStatus.find("VERIFIED")
    # Create a staff identity telephone with this status
    staff = Staff.create!(public_id: "test-staff-#{SecureRandom.hex(4)}")
    StaffIdentityTelephone.create!(
      id: SecureRandom.uuid,
      number: "+81901234567",
      staff_id: staff.id,
      staff_identity_telephone_status_id: status.id,
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
