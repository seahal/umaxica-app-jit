# == Schema Information
#
# Table name: app_timeline_audit_levels
#
#  id         :string           default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class AppTimelineAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = app_timeline_audit_levels(:none)
    timeline = AppTimeline.new
    timeline.save!(validate: false)

    AppTimelineAudit.create!(
      app_timeline: timeline,
      app_timeline_audit_event: app_timeline_audit_events(:CREATED),
      app_timeline_audit_level: level
    )

    assert_no_difference "AppTimelineAuditLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "app timeline auditsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = AppTimelineAuditLevel.create!(id: "UNUSED")

    assert_difference "AppTimelineAuditLevel.count", -1 do
      assert level.destroy
    end
  end
end
