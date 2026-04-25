# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
class ComPreferenceActivityLevel < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - unified across App/Org/Com (aligned to App pattern)
  NOTHING = 0
  INFO = 1

  has_many :com_preference_activities, dependent: :restrict_with_error, inverse_of: :com_preference_activity_level

  DEFAULTS = [NOTHING, INFO].freeze

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
