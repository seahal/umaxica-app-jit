# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComTimelineAuditLevelTest < ActiveSupport::TestCase
  fixtures :com_timeline_audit_levels, :com_timeline_audit_events, :com_timeline_statuses

  test "restrict_with_error on destroy when audits exist" do
    level = ComTimelineAuditLevel.find(ComTimelineAuditLevel::NEYO)
    timeline = ComTimeline.create!(
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      status_id: ComTimelineStatus::NEYO,
    )

    ComTimelineAudit.create!(
      com_timeline: timeline,
      com_timeline_audit_event: ComTimelineAuditEvent.find(ComTimelineAuditEvent::CREATED),
      com_timeline_audit_level: level,
    )

    assert_no_difference "ComTimelineAuditLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "com timeline auditsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = ComTimelineAuditLevel.create!(id: 2)

    assert_difference "ComTimelineAuditLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = ComTimelineAuditLevel.new(id: 3)
    assert_predicate record, :valid?
  end
end
