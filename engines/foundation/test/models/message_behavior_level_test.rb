# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: message_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class MessageBehaviorLevelTest < ActiveSupport::TestCase
  fixtures :message_behavior_levels, :message_behavior_events

  test "has correct constants" do
    assert_equal 0, MessageBehaviorLevel::NOTHING
  end

  test "can load nothing status from db" do
    status = MessageBehaviorLevel.find(MessageBehaviorLevel::NOTHING)

    assert_equal 0, status.id
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "MessageBehaviorLevel.count" do
      MessageBehaviorLevel.ensure_defaults!
    end
  end

  test "restrict_with_error on destroy when behaviors exist" do
    level = MessageBehaviorLevel.find(MessageBehaviorLevel::NOTHING)

    MessageBehaviorEvent.find_or_create_by!(id: MessageBehaviorEvent::SENT)
    behavior = MessageBehavior.create!(
      subject_id: 1,
      subject_type: "Message",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: MessageBehaviorEvent::SENT,
      level_id: level.id,
    )

    assert_no_difference "MessageBehaviorLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "message behaviorsが存在しているので削除できません", level.errors[:base].first
  ensure
    behavior&.destroy
  end

  test "can destroy when no audits exist" do
    level = MessageBehaviorLevel.create!(id: 99)

    assert_difference "MessageBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = MessageBehaviorLevel.new(id: 3)

    assert_predicate record, :valid?
  end
end
