# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: search_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class SearchBehaviorEvent < BehaviorRecord
  self.record_timestamps = false
  NOTHING = 0
  QUERY_EXECUTED = 1
  INDEX_UPDATED = 2
  INDEX_REBUILT = 3
  DEFAULTS = [NOTHING, QUERY_EXECUTED, INDEX_UPDATED, INDEX_REBUILT].freeze

  has_many :search_behaviors,
           class_name: "SearchBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :search_behavior_event,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
