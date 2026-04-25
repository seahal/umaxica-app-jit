# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: message_behaviors
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
#  index_message_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_message_behaviors_on_event_id                     (event_id)
#  index_message_behaviors_on_level_id                     (level_id)
#  index_message_behaviors_on_subject_id                   (subject_id)
#  index_message_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => message_behavior_events.id)
#  fk_rails_...  (level_id => message_behavior_levels.id)
#

require "test_helper"

class MessageBehaviorTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "message_behaviors", MessageBehavior.table_name
  end

  test "validates subject_id presence" do
    behavior = MessageBehavior.new(
      subject_id: nil,
      subject_type: "Message",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: MessageBehaviorEvent::SENT,
      level_id: MessageBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:subject_id], "を入力してください"
  end

  test "validates subject_type presence" do
    behavior = MessageBehavior.new(
      subject_id: 1,
      subject_type: nil,
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: MessageBehaviorEvent::SENT,
      level_id: MessageBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:subject_type], "を入力してください"
  end

  test "rejects unknown event_id before database foreign key enforcement" do
    behavior = MessageBehavior.new(
      subject_id: 1,
      subject_type: "Message",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: 999_999,
      level_id: MessageBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:event_id], "must reference an existing message_behavior_event"
  end

  test "rejects unknown level_id before database foreign key enforcement" do
    behavior = MessageBehavior.new(
      subject_id: 1,
      subject_type: "Message",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: MessageBehaviorEvent::SENT,
      level_id: 999_999,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:level_id], "must reference an existing message_behavior_level"
  end

  test "event_id rejects negative values" do
    behavior = MessageBehavior.new(
      subject_id: 1,
      subject_type: "Message",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: -1,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:event_id]
  end

  test "event_id rejects decimal values" do
    behavior = MessageBehavior.new(
      subject_id: 1,
      subject_type: "Message",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: 1.5,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:event_id]
  end

  test "level_id rejects negative values" do
    behavior = MessageBehavior.new(
      subject_id: 1,
      subject_type: "Message",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      level_id: -1,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:level_id]
  end

  test "level_id rejects decimal values" do
    behavior = MessageBehavior.new(
      subject_id: 1,
      subject_type: "Message",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      level_id: 1.5,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:level_id]
  end

  test "messageable helper method returns nil when subject_type is not Message" do
    audit = MessageBehavior.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_nil audit.messageable
  end

  test "messageable helper method returns the Message record when subject_type matches" do
    message = UserMessage.create!(user: users(:one))
    audit = MessageBehavior.new(
      subject_id: message.id,
      subject_type: "UserMessage",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_equal message, audit.messageable
  end

  test "messageable helper method tolerates missing model class" do
    audit = MessageBehavior.new(
      subject_id: 123,
      subject_type: "MissingMessage",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_nil audit.messageable
  end

  test "messageable helper method does not define a writer shortcut" do
    test_id = 123
    audit = MessageBehavior.new

    assert_raises(NoMethodError) { audit.message = test_id }
  end
end
