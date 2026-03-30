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
  test "has correct constants" do
    assert_equal 0, AppTimelineBehaviorLevel::NOTHING
    assert_equal 1, AppTimelineBehaviorLevel::LEGACY_NOTHING
    assert_equal 2, AppTimelineBehaviorLevel::DEBUG
    assert_equal 3, AppTimelineBehaviorLevel::INFO
    assert_equal 4, AppTimelineBehaviorLevel::WARN
    assert_equal 5, AppTimelineBehaviorLevel::ERROR
  end

  test "can load nothing status from db" do
    status = AppTimelineBehaviorLevel.find(AppTimelineBehaviorLevel::NOTHING)

    assert_equal 0, status.id
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "AppTimelineBehaviorLevel.count" do
      AppTimelineBehaviorLevel.ensure_defaults!
    end
  end

  test "restrict_with_error on destroy when audits exist" do
    level = AppTimelineBehaviorLevel.find_or_create_by!(id: AppTimelineBehaviorLevel::NOTHING)
    AppTimelineBehaviorEvent.find_or_create_by!(id: AppTimelineBehaviorEvent::CREATED)
    timeline = AppTimeline.create!(
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      status_id: AppTimelineStatus::NOTHING,
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
