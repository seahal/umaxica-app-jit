# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_audit_levels
# Database name: audit
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgTimelineAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    I18n.with_locale(:ja) do
      level = OrgTimelineAuditLevel.find_or_create_by!(id: OrgTimelineAuditLevel::NEYO)
      OrgTimelineAuditEvent.find_or_create_by!(id: OrgTimelineAuditEvent::CREATED)
      timeline = OrgTimeline.create!(
        response_mode: "html",
        published_at: 1.hour.ago,
        expires_at: 1.hour.from_now,
        position: 0,
        status_id: OrgTimelineStatus::NEYO,
      )

      OrgTimelineAudit.create!(
        org_timeline: timeline,
        org_timeline_audit_event: OrgTimelineAuditEvent.find(OrgTimelineAuditEvent::CREATED),
        org_timeline_audit_level: level,
      )

      assert_no_difference "OrgTimelineAuditLevel.count" do
        assert_not level.destroy
      end
      assert_not_empty level.errors[:base]
      assert_equal "org timeline auditsが存在しているので削除できません", level.errors[:base].first
    end
  end

  test "can destroy when no audits exist" do
    level = OrgTimelineAuditLevel.create!(id: 2)

    assert_difference "OrgTimelineAuditLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = OrgTimelineAuditLevel.new(id: 3)
    assert_predicate record, :valid?
  end
end
