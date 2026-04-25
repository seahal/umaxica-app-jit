# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: search_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class SearchBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = SearchBehaviorEvent
    @valid_id = SearchBehaviorEvent::QUERY_EXECUTED
    @subject = @model_class.new(id: @valid_id)
  end

  test "has correct constants" do
    assert_equal 0, SearchBehaviorEvent::NOTHING
    assert_equal 1, SearchBehaviorEvent::QUERY_EXECUTED
    assert_equal 2, SearchBehaviorEvent::INDEX_UPDATED
    assert_equal 3, SearchBehaviorEvent::INDEX_REBUILT
  end

  test "accepts integer ids" do
    record = SearchBehaviorEvent.new(id: 2)

    assert_predicate record, :valid?
  end

  test "allows nil id on new records" do
    record = SearchBehaviorEvent.new(id: nil)

    assert_predicate record, :valid?
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "SearchBehaviorEvent.count" do
      SearchBehaviorEvent.ensure_defaults!
    end
  end

  test "ensure_defaults! creates missing defaults" do
    SearchBehaviorEvent.where(id: SearchBehaviorEvent::DEFAULTS).delete_all

    assert_difference "SearchBehaviorEvent.count", 4 do
      SearchBehaviorEvent.ensure_defaults!
    end

    assert_not_nil SearchBehaviorEvent.find_by(id: SearchBehaviorEvent::NOTHING)
    assert_not_nil SearchBehaviorEvent.find_by(id: SearchBehaviorEvent::QUERY_EXECUTED)
    assert_not_nil SearchBehaviorEvent.find_by(id: SearchBehaviorEvent::INDEX_UPDATED)
    assert_not_nil SearchBehaviorEvent.find_by(id: SearchBehaviorEvent::INDEX_REBUILT)
  end
end
