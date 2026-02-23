# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppTimelineBehaviorLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = AppTimelineBehaviorLevel.find_or_create_by!(id: AppTimelineBehaviorLevel::NEYO)
    AppTimelineBehaviorEvent.find_or_create_by!(id: AppTimelineBehaviorEvent::CREATED)
    timeline = AppTimeline.create!(
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      status_id: AppTimelineStatus::NEYO,
    )

    AppTimelineBehavior.create!(
      app_timeline: timeline,
      app_timeline_behavior_event: AppTimelineBehaviorEvent.find(AppTimelineBehaviorEvent::CREATED),
      app_timeline_behavior_level: level,
    )

    assert_no_difference "AppTimelineBehaviorLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "app timeline behaviorsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = AppTimelineBehaviorLevel.create!(id: 99)

    assert_difference "AppTimelineBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = AppTimelineBehaviorLevel.new(id: 3)
    assert_predicate record, :valid?
  end
end
