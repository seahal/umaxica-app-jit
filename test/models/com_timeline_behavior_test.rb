# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_behaviors
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
#  index_com_timeline_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_com_timeline_behaviors_on_event_id                     (event_id)
#  index_com_timeline_behaviors_on_level_id                     (level_id)
#  index_com_timeline_behaviors_on_subject_id                   (subject_id)
#  index_com_timeline_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => com_timeline_behavior_events.id)
#  fk_rails_...  (level_id => com_timeline_behavior_levels.id)
#

require "test_helper"

class ComTimelineBehaviorTest < ActiveSupport::TestCase
  fixtures :com_timelines, :com_timeline_behavior_events, :com_timeline_behavior_levels
  test "loads model and associations" do
    assert_equal "com_timeline_behaviors", ComTimelineBehavior.table_name

    refl = ComTimelineBehavior.reflect_on_association(:com_timeline)

    assert_not_nil refl, "expected belongs_to :com_timeline association"
    assert_equal :belongs_to, refl.macro

    refl_level = ComTimelineBehavior.reflect_on_association(:com_timeline_behavior_level)
    assert_not_nil refl_level, "expected belongs_to :com_timeline_behavior_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "com_timeline helper method returns nil when subject_type is not ComTimeline" do
    audit = ComTimelineBehavior.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )
    assert_nil audit.com_timeline
  end

  test "com_timeline helper method resolves when subject_type is ComTimeline" do
    timeline = com_timelines(:one)
    audit = ComTimelineBehavior.new(
      subject_id: timeline.id,
      subject_type: "ComTimeline",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: com_timeline_behavior_events(:created).id,
      level_id: com_timeline_behavior_levels(:neyo).id,
    )

    assert_equal timeline, audit.com_timeline
  end

  test "com_timeline= helper method sets subject_id and subject_type" do
    test_id = 123

    timeline = ComTimeline.new
    timeline.define_singleton_method(:id) { test_id }

    audit = ComTimelineBehavior.new
    audit.com_timeline = timeline

    assert_equal test_id, audit.subject_id
    assert_equal "ComTimeline", audit.subject_type
  end
end
