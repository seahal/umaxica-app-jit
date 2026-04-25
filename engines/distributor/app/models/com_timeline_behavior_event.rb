# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class ComTimelineBehaviorEvent < BehaviorRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NOTHING = 0
  LEGACY_NOTHING = 1
  CREATED = 2
  UPDATED = 3
  DELETED = 4
  DEFAULTS = [NOTHING, LEGACY_NOTHING, CREATED, UPDATED, DELETED].freeze

  has_many :com_timeline_behaviors,
           class_name: "ComTimelineBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_timeline_behavior_event,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
