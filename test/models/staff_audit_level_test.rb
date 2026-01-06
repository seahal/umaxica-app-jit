# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_levels
#
#  id         :string           default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class StaffAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = StaffAuditLevel.find("NEYO")
    StaffAudit.create!(
      staff: Staff.find_by!(public_id: "one_staff_id"),
      staff_audit_event: StaffAuditEvent.find("LOGIN_SUCCESS"),
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
    level = StaffAuditLevel.create!(id: "UNUSED")

    assert_difference "StaffAuditLevel.count", -1 do
      assert level.destroy
    end
  end
end
