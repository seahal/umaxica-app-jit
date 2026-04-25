# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: message_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class MessageBehaviorLevel < BehaviorRecord
  self.record_timestamps = false
  NOTHING = 0
  DEFAULTS = [NOTHING].freeze

  has_many :message_behaviors, dependent: :restrict_with_error, inverse_of: :message_behavior_level

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
