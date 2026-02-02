# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_levels
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_audit_levels_on_code  (code) UNIQUE
#

require "test_helper"

class StaffAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = StaffAuditLevel.find("NEYO")
    StaffAudit.create!(
      staff: Staff.find_by!(public_id: "bcde3456"),
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

  test "validates length of id" do
    record = StaffAuditLevel.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
