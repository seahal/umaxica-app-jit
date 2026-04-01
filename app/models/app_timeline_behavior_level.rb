# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class AppTimelineBehaviorLevel < BehaviorRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NOTHING = 0
  LEGACY_NOTHING = 1
  DEBUG = 2
  INFO = 3
  WARN = 4
  ERROR = 5
  DEFAULTS = [NOTHING, LEGACY_NOTHING, DEBUG, INFO, WARN, ERROR].freeze

  has_many :app_timeline_behaviors, dependent: :restrict_with_error, inverse_of: :app_timeline_behavior_level

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
