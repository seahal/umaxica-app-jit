require "test_helper"

class ComTimelineAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = com_timeline_audit_levels(:none)
    timeline = ComTimeline.new
    timeline.save!(validate: false)

    ComTimelineAudit.create!(
      com_timeline: timeline,
      com_timeline_audit_event: com_timeline_audit_events(:CREATED),
      com_timeline_audit_level: level
    )

    assert_no_difference "ComTimelineAuditLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "com timeline auditsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = ComTimelineAuditLevel.create!(id: "UNUSED")

    assert_difference "ComTimelineAuditLevel.count", -1 do
      assert level.destroy
    end
  end
end
