# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_behavior_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComTimelineBehaviorLevelTest < ActiveSupport::TestCase
  fixtures :com_timeline_behavior_levels, :com_timeline_behavior_events, :com_timeline_statuses

  test "restrict_with_error on destroy when audits exist" do
    level = ComTimelineBehaviorLevel.find(ComTimelineBehaviorLevel::NEYO)
    timeline = ComTimeline.create!(
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      status_id: ComTimelineStatus::NEYO,
    )

    ComTimelineBehavior.create!(
      com_timeline: timeline,
      com_timeline_behavior_event: ComTimelineBehaviorEvent.find(ComTimelineBehaviorEvent::CREATED),
      com_timeline_behavior_level: level,
    )

    assert_no_difference "ComTimelineBehaviorLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "com timeline behaviorsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = ComTimelineBehaviorLevel.create!(id: 2)

    assert_difference "ComTimelineBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = ComTimelineBehaviorLevel.new(id: 3)
    assert_predicate record, :valid?
  end
end
