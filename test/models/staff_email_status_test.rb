# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_email_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#

require "test_helper"

class StaffEmailStatusTest < ActiveSupport::TestCase
  fixtures :staff_email_statuses

  test "valid status with id" do
    status = StaffEmailStatus.find(StaffEmailStatus::UNVERIFIED)

    assert_predicate status, :valid?
  end

  test "has many staff_emails" do
    assert StaffEmailStatus.reflect_on_association(:staff_emails)
  end

  test "status constants are defined" do
    assert_equal 6, StaffEmailStatus::UNVERIFIED
    assert_equal 7, StaffEmailStatus::VERIFIED
  end

  test "additional status constants are defined" do
    assert_equal 1, StaffEmailStatus::ACTIVE
    assert_equal 2, StaffEmailStatus::DELETED
  end

  test "restrict_with_error prevents deletion when emails exist" do
    status = StaffEmailStatus.find(StaffEmailStatus::VERIFIED)
    # Create a staff identity email with this status
    staff = Staff.create!
    StaffEmail.create!(
      address: "staff@example.com",
      staff_id: staff.id,
      staff_email_status_id: status.id,
      public_id: "email#{SecureRandom.hex(6)}",
      otp_counter: "1",
      otp_private_key: "secret",
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
