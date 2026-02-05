# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_audit_levels
# Database name: audit
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppTimelineAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = AppTimelineAuditLevel.find_or_create_by!(id: AppTimelineAuditLevel::NEYO)
    AppTimelineAuditEvent.find_or_create_by!(id: AppTimelineAuditEvent::CREATED)
    timeline = AppTimeline.create!(
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      status_id: AppTimelineStatus::NEYO,
    )

    AppTimelineAudit.create!(
      app_timeline: timeline,
      app_timeline_audit_event: AppTimelineAuditEvent.find(AppTimelineAuditEvent::CREATED),
      app_timeline_audit_level: level,
    )

    assert_no_difference "AppTimelineAuditLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "app timeline auditsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = AppTimelineAuditLevel.create!(id: 99)

    assert_difference "AppTimelineAuditLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = AppTimelineAuditLevel.new(id: 3)
    assert_predicate record, :valid?
  end
end
