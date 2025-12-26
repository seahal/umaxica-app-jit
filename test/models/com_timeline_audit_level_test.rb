# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_audit_levels
#
#  id         :string(255)      default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class ComTimelineAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = com_timeline_audit_levels(:none)
    timeline = ComTimeline.create!(
      permalink: "audit_timeline",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key",
    )

    ComTimelineAudit.create!(
      com_timeline: timeline,
      com_timeline_audit_event: com_timeline_audit_events(:CREATED),
      com_timeline_audit_level: level,
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
