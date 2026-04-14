# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: message_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class MessageBehaviorEvent < BehaviorRecord
  self.record_timestamps = false
  NOTHING = 0
  SENT = 1
  UPDATED = 2
  DELETED = 3
  DELIVERED = 4
  DELIVERY_FAILED = 5
  MODERATION_APPLIED = 6
  DEFAULTS = [NOTHING, SENT, UPDATED, DELETED, DELIVERED, DELIVERY_FAILED, MODERATION_APPLIED].freeze

  has_many :message_behaviors,
           class_name: "MessageBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :message_behavior_event,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
