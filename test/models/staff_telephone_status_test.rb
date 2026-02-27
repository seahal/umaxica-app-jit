# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_telephone_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#

require "test_helper"

class StaffTelephoneStatusTest < ActiveSupport::TestCase
  fixtures :staff_telephone_statuses, :staffs, :staff_statuses

  test "valid status with id" do
    status = StaffTelephoneStatus.find(StaffTelephoneStatus::UNVERIFIED)

    assert_predicate status, :valid?
  end

  test "has many staff_telephones" do
    assert StaffTelephoneStatus.reflect_on_association(:staff_telephones)
  end

  test "status constants are defined" do
    assert_equal 6, StaffTelephoneStatus::UNVERIFIED
    assert_equal 7, StaffTelephoneStatus::VERIFIED
  end

  test "additional status constants are defined" do
    assert_equal 1, StaffTelephoneStatus::ACTIVE
    assert_equal 2, StaffTelephoneStatus::DELETED
  end

  test "restrict_with_error prevents deletion when telephones exist" do
    status = StaffTelephoneStatus.find(StaffTelephoneStatus::VERIFIED)
    # Create a staff identity telephone with this status
    staff = Staff.create!
    StaffTelephone.create!(
      number: "+81901234567",
      staff_id: staff.id,
      staff_telephone_status_id: status.id,
      otp_counter: "1",
      otp_private_key: "secret",
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
