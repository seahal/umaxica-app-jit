# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class StaffAuditLevelTest < ActiveSupport::TestCase
  fixtures :staffs, :staff_statuses, :staff_audit_levels, :staff_audit_events

  test "restrict_with_error on destroy when audits exist" do
    level = StaffAuditLevel.find(StaffAuditLevel::NEYO)
    StaffAudit.create!(
      staff: Staff.find_by!(public_id: "bcde3456"),
      staff_audit_event: StaffAuditEvent.find(StaffAuditEvent::LOGIN_SUCCESS),
      staff_audit_level: level,
      timestamp: Time.current,
    )

    assert_no_difference "StaffAuditLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "staff auditsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = StaffAuditLevel.create!(id: 2)

    assert_difference "StaffAuditLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = StaffAuditLevel.new(id: 3)
    assert_predicate record, :valid?
  end
end
