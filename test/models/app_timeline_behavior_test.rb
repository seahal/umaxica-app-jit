# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_behaviors
# Database name: behavior
#
#  id           :bigint           not null, primary key
#  actor_type   :string
#  expires_at   :datetime
#  occurred_at  :datetime
#  subject_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  actor_id     :bigint
#  event_id     :bigint           not null
#  level_id     :bigint           not null
#  subject_id   :bigint           not null
#
# Indexes
#
#  index_app_timeline_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_app_timeline_behaviors_on_event_id                     (event_id)
#  index_app_timeline_behaviors_on_level_id                     (level_id)
#  index_app_timeline_behaviors_on_subject_id                   (subject_id)
#  index_app_timeline_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => app_timeline_behavior_events.id)
#  fk_rails_...  (level_id => app_timeline_behavior_levels.id)
#

require "test_helper"

class AppTimelineBehaviorTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "app_timeline_behaviors", AppTimelineBehavior.table_name

    refl = AppTimelineBehavior.reflect_on_association(:app_timeline)

    assert_not_nil refl, "expected belongs_to :app_timeline association"
    assert_equal :belongs_to, refl.macro

    refl_level = AppTimelineBehavior.reflect_on_association(:app_timeline_behavior_level)

    assert_not_nil refl_level, "expected belongs_to :app_timeline_behavior_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "app_timeline helper method returns nil when subject_type is not AppTimeline" do
    audit = AppTimelineBehavior.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_nil audit.app_timeline
  end

  test "app_timeline= helper method sets subject_id and subject_type" do
    test_id = 123

    timeline = AppTimeline.new
    timeline.define_singleton_method(:id) { test_id }

    audit = AppTimelineBehavior.new
    audit.app_timeline = timeline

    assert_equal test_id, audit.subject_id
    assert_equal "AppTimeline", audit.subject_type
  end

  test "app_timeline helper method returns timeline when subject_type is AppTimeline" do
    AppTimelineBehaviorEvent.find_or_create_by!(id: AppTimelineBehaviorEvent::NOTHING)
    AppTimelineBehaviorLevel.find_or_create_by!(id: AppTimelineBehaviorLevel::NOTHING)
    # Ensure status exists
    AppTimelineStatus.find_or_create_by!(id: AppTimelineStatus::NOTHING)

    timeline = AppTimeline.create!(
      status_id: AppTimelineStatus::NOTHING,
      slug_id: "tl-#{SecureRandom.hex(4)}",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )
    audit = AppTimelineBehavior.create!(
      subject_id: timeline.id,
      subject_type: "AppTimeline",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_equal timeline, audit.app_timeline
  end
end
