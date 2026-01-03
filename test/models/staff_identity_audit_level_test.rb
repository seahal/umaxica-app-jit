# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_audit_levels
#
#  id :string(255)      default("NEYO"), not null, primary key
#

require "test_helper"

class StaffIdentityAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = StaffIdentityAuditLevel.find("NEYO")
    StaffIdentityAudit.create!(
      staff: Staff.find_by!(public_id: "one_staff_id"),
      staff_identity_audit_event: StaffIdentityAuditEvent.find("LOGIN_SUCCESS"),
      staff_identity_audit_level: level,
      timestamp: Time.current,
    )

    assert_no_difference "StaffIdentityAuditLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "staff identity auditsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = StaffIdentityAuditLevel.create!(id: "UNUSED")

    assert_difference "StaffIdentityAuditLevel.count", -1 do
      assert level.destroy
    end
  end
end
