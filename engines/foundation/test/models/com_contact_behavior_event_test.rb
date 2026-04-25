# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComContactBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = ComContactBehaviorEvent
    @valid_id = ComContactBehaviorEvent::SUBMITTED
    @subject = @model_class.new(id: @valid_id)
  end

  test "has correct constants" do
    assert_equal 0, ComContactBehaviorEvent::NOTHING
    assert_equal 1, ComContactBehaviorEvent::SUBMITTED
    assert_equal 2, ComContactBehaviorEvent::UPDATED
    assert_equal 3, ComContactBehaviorEvent::VERIFICATION_STARTED
    assert_equal 4, ComContactBehaviorEvent::VERIFICATION_COMPLETED
  end

  test "accepts integer ids" do
    record = ComContactBehaviorEvent.new(id: 5)

    assert_predicate record, :valid?
  end

  test "allows nil id on new records" do
    record = ComContactBehaviorEvent.new(id: nil)

    assert_predicate record, :valid?
  end

  test "ensure_defaults! does nothing when defaults exist" do
    ComContactBehaviorEvent.ensure_defaults!

    assert_no_difference "ComContactBehaviorEvent.count" do
      ComContactBehaviorEvent.ensure_defaults!
    end
  end

  test "ensure_defaults! creates missing defaults" do
    ComContactBehaviorEvent.where(id: ComContactBehaviorEvent::DEFAULTS).delete_all

    assert_difference "ComContactBehaviorEvent.count", 5 do
      ComContactBehaviorEvent.ensure_defaults!
    end

    assert_not_nil ComContactBehaviorEvent.find_by(id: ComContactBehaviorEvent::NOTHING)
    assert_not_nil ComContactBehaviorEvent.find_by(id: ComContactBehaviorEvent::SUBMITTED)
  end
end
