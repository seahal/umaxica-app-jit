# == Schema Information
#
# Table name: org_timeline_audit_levels
#
#  id         :string(255)      default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class OrgTimelineAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = org_timeline_audit_levels(:none)
    # create generic parent for audit
    timeline = OrgTimeline.new
    timeline.save!(validate: false) # Bypassing validations if any for generic parent setup

    OrgTimelineAudit.create!(
      org_timeline: timeline,
      org_timeline_audit_event: org_timeline_audit_events(:CREATED),
      org_timeline_audit_level: level
    )

    assert_no_difference "OrgTimelineAuditLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "org timeline auditsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = OrgTimelineAuditLevel.create!(id: "UNUSED")

    assert_difference "OrgTimelineAuditLevel.count", -1 do
      assert level.destroy
    end
  end
end
