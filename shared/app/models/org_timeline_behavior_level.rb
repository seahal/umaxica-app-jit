# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#
class OrgTimelineBehaviorLevel < BehaviorRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NOTHING = 1
  DEBUG = 2
  INFO = 3
  WARN = 4
  ERROR = 5
  DEFAULTS = [NOTHING, DEBUG, INFO, WARN, ERROR].freeze

  has_many :org_timeline_behaviors, dependent: :restrict_with_error, inverse_of: :org_timeline_behavior_level

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
