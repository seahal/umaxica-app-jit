# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_audit_levels
#
#  id :string(255)      default("NEYO"), not null, primary key
#

require "test_helper"

class AppTimelineAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = AppTimelineAuditLevel.find_or_create_by!(id: "TEST_LEVEL")
    AppTimelineAuditEvent.find_or_create_by!(id: "CREATED")
    timeline = AppTimeline.create!(
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
    )

    AppTimelineAudit.create!(
      app_timeline: timeline,
      app_timeline_audit_event: AppTimelineAuditEvent.find("CREATED"),
      app_timeline_audit_level: level,
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
