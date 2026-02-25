# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_behaviors
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
#  index_org_timeline_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_org_timeline_behaviors_on_event_id                     (event_id)
#  index_org_timeline_behaviors_on_level_id                     (level_id)
#  index_org_timeline_behaviors_on_subject_id                   (subject_id)
#  index_org_timeline_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => org_timeline_behavior_events.id)
#  fk_rails_...  (level_id => org_timeline_behavior_levels.id)
#

require "test_helper"

class OrgTimelineBehaviorTest < ActiveSupport::TestCase
  fixtures :org_timelines
  test "loads model and associations" do
    assert_equal "org_timeline_behaviors", OrgTimelineBehavior.table_name

    refl = OrgTimelineBehavior.reflect_on_association(:org_timeline)

    assert_not_nil refl, "expected belongs_to :org_timeline association"
    assert_equal :belongs_to, refl.macro

    refl_level = OrgTimelineBehavior.reflect_on_association(:org_timeline_behavior_level)

    assert_not_nil refl_level, "expected belongs_to :org_timeline_behavior_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "org_timeline helper method returns nil when subject_type is not OrgTimeline" do
    audit = OrgTimelineBehavior.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_nil audit.org_timeline
  end

  test "org_timeline helper method resolves when subject_type is OrgTimeline" do
    timeline = org_timelines(:one)
    audit = OrgTimelineBehavior.new(
      subject_id: timeline.id,
      subject_type: "OrgTimeline",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: OrgTimelineBehaviorEvent::NEYO,
      level_id: OrgTimelineBehaviorLevel::NEYO,
    )

    assert_equal timeline, audit.org_timeline
  end

  test "org_timeline= helper method sets subject_id and subject_type" do
    test_id = 123

    timeline = OrgTimeline.new
    timeline.define_singleton_method(:id) { test_id }

    audit = OrgTimelineBehavior.new
    audit.org_timeline = timeline

    assert_equal test_id, audit.subject_id
    assert_equal "OrgTimeline", audit.subject_type
  end
end
