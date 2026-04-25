# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: message_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class MessageBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = MessageBehaviorEvent
    @valid_id = MessageBehaviorEvent::SENT
    @subject = @model_class.new(id: @valid_id)
  end

  test "has correct constants" do
    assert_equal 0, MessageBehaviorEvent::NOTHING
    assert_equal 1, MessageBehaviorEvent::SENT
    assert_equal 2, MessageBehaviorEvent::UPDATED
    assert_equal 3, MessageBehaviorEvent::DELETED
    assert_equal 4, MessageBehaviorEvent::DELIVERED
    assert_equal 5, MessageBehaviorEvent::DELIVERY_FAILED
    assert_equal 6, MessageBehaviorEvent::MODERATION_APPLIED
  end

  test "accepts integer ids" do
    record = MessageBehaviorEvent.new(id: 2)

    assert_predicate record, :valid?
  end

  test "allows nil id on new records" do
    record = MessageBehaviorEvent.new(id: nil)

    assert_predicate record, :valid?
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "MessageBehaviorEvent.count" do
      MessageBehaviorEvent.ensure_defaults!
    end
  end

  test "ensure_defaults! creates missing defaults" do
    MessageBehaviorEvent.where(id: MessageBehaviorEvent::DEFAULTS).delete_all

    assert_difference "MessageBehaviorEvent.count", 7 do
      MessageBehaviorEvent.ensure_defaults!
    end

    assert_not_nil MessageBehaviorEvent.find_by(id: MessageBehaviorEvent::NOTHING)
    assert_not_nil MessageBehaviorEvent.find_by(id: MessageBehaviorEvent::SENT)
    assert_not_nil MessageBehaviorEvent.find_by(id: MessageBehaviorEvent::UPDATED)
    assert_not_nil MessageBehaviorEvent.find_by(id: MessageBehaviorEvent::DELETED)
    assert_not_nil MessageBehaviorEvent.find_by(id: MessageBehaviorEvent::DELIVERED)
    assert_not_nil MessageBehaviorEvent.find_by(id: MessageBehaviorEvent::DELIVERY_FAILED)
    assert_not_nil MessageBehaviorEvent.find_by(id: MessageBehaviorEvent::MODERATION_APPLIED)
  end
end
