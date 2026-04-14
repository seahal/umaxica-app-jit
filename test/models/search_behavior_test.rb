# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: search_behaviors
# Database name: behavior
#
#  id           :bigint           not null, primary key
#  actor_type   :string
#  expires_at   :datetime
#  occurred_at  :datetime         not null
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
#  index_search_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_search_behaviors_on_event_id                     (event_id)
#  index_search_behaviors_on_level_id                     (level_id)
#  index_search_behaviors_on_subject_id                   (subject_id)
#  index_search_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => search_behavior_events.id)
#  fk_rails_...  (level_id => search_behavior_levels.id)
#

require "test_helper"

class SearchBehaviorTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "search_behaviors", SearchBehavior.table_name
  end

  test "validates subject_id presence" do
    behavior = SearchBehavior.new(
      subject_id: nil,
      subject_type: "Search",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: SearchBehaviorEvent::QUERY_EXECUTED,
      level_id: SearchBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:subject_id], "を入力してください"
  end

  test "validates subject_type presence" do
    behavior = SearchBehavior.new(
      subject_id: 1,
      subject_type: nil,
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: SearchBehaviorEvent::QUERY_EXECUTED,
      level_id: SearchBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:subject_type], "を入力してください"
  end

  test "rejects unknown event_id before database foreign key enforcement" do
    behavior = SearchBehavior.new(
      subject_id: 1,
      subject_type: "Search",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: 999_999,
      level_id: SearchBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:event_id], "must reference an existing search_behavior_event"
  end

  test "rejects unknown level_id before database foreign key enforcement" do
    behavior = SearchBehavior.new(
      subject_id: 1,
      subject_type: "Search",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: SearchBehaviorEvent::QUERY_EXECUTED,
      level_id: 999_999,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:level_id], "must reference an existing search_behavior_level"
  end

  test "event_id rejects negative values" do
    behavior = SearchBehavior.new(
      subject_id: 1,
      subject_type: "Search",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: -1,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:event_id]
  end

  test "event_id rejects decimal values" do
    behavior = SearchBehavior.new(
      subject_id: 1,
      subject_type: "Search",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: 1.5,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:event_id]
  end

  test "level_id rejects negative values" do
    behavior = SearchBehavior.new(
      subject_id: 1,
      subject_type: "Search",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      level_id: -1,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:level_id]
  end

  test "level_id rejects decimal values" do
    behavior = SearchBehavior.new(
      subject_id: 1,
      subject_type: "Search",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      level_id: 1.5,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:level_id]
  end

  test "searchable helper method returns nil when subject_type is not Search" do
    audit = SearchBehavior.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_nil audit.searchable
  end

  test "searchable helper method returns the Search record when subject_type matches" do
    user = users(:one)
    audit = SearchBehavior.new(
      subject_id: user.id,
      subject_type: "User",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_equal user, audit.searchable
  end

  test "searchable helper method tolerates missing model class" do
    audit = SearchBehavior.new(
      subject_id: 123,
      subject_type: "MissingSearch",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_nil audit.searchable
  end

  test "searchable helper method does not define a writer shortcut" do
    test_id = 123
    audit = SearchBehavior.new

    assert_raises(NoMethodError) { audit.search = test_id }
  end
end
