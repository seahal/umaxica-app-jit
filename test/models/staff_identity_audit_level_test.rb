require "test_helper"

class StaffIdentityAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = staff_identity_audit_levels(:none)
    StaffIdentityAudit.create!(
      staff: staffs(:one),
      staff_identity_audit_event: staff_identity_audit_events(:one),
      staff_identity_audit_level: level,
      timestamp: Time.current
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
