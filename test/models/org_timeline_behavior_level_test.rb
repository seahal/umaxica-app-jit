# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgTimelineBehaviorLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    I18n.with_locale(:ja) do
      level = OrgTimelineBehaviorLevel.find_or_create_by!(id: OrgTimelineBehaviorLevel::NEYO)
      OrgTimelineBehaviorEvent.find_or_create_by!(id: OrgTimelineBehaviorEvent::CREATED)
      timeline = OrgTimeline.create!(
        response_mode: "html",
        published_at: 1.hour.ago,
        expires_at: 1.hour.from_now,
        position: 0,
        status_id: OrgTimelineStatus::NEYO,
      )

      OrgTimelineBehavior.create!(
        org_timeline: timeline,
        org_timeline_behavior_event: OrgTimelineBehaviorEvent.find(OrgTimelineBehaviorEvent::CREATED),
        org_timeline_behavior_level: level,
      )

      assert_no_difference "OrgTimelineBehaviorLevel.count" do
        assert_not level.destroy
      end
      assert_not_empty level.errors[:base]
      assert_equal "org timeline behaviorsが存在しているので削除できません", level.errors[:base].first
    end
  end

  test "can destroy when no audits exist" do
    level = OrgTimelineBehaviorLevel.create!(id: 2)

    assert_difference "OrgTimelineBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = OrgTimelineBehaviorLevel.new(id: 3)
    assert_predicate record, :valid?
  end
end
