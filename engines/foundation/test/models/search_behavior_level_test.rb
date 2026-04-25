# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: search_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class SearchBehaviorLevelTest < ActiveSupport::TestCase
  fixtures :search_behavior_levels, :search_behavior_events

  test "has correct constants" do
    assert_equal 0, SearchBehaviorLevel::NOTHING
  end

  test "can load nothing status from db" do
    status = SearchBehaviorLevel.find(SearchBehaviorLevel::NOTHING)

    assert_equal 0, status.id
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "SearchBehaviorLevel.count" do
      SearchBehaviorLevel.ensure_defaults!
    end
  end

  test "restrict_with_error on destroy when behaviors exist" do
    level = SearchBehaviorLevel.find(SearchBehaviorLevel::NOTHING)

    SearchBehaviorEvent.find_or_create_by!(id: SearchBehaviorEvent::QUERY_EXECUTED)
    behavior = SearchBehavior.create!(
      subject_id: 1,
      subject_type: "Search",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: SearchBehaviorEvent::QUERY_EXECUTED,
      level_id: level.id,
    )

    assert_no_difference "SearchBehaviorLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "search behaviorsが存在しているので削除できません", level.errors[:base].first
  ensure
    behavior&.destroy
  end

  test "can destroy when no audits exist" do
    level = SearchBehaviorLevel.create!(id: 99)

    assert_difference "SearchBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = SearchBehaviorLevel.new(id: 3)

    assert_predicate record, :valid?
  end
end
