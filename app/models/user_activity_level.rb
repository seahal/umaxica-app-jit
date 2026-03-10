# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
class UserActivityLevel < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  DEBUG = 1
  ERROR = 2
  INFO = 3
  NOTHING = 4
  WARN = 5

  has_many :user_activities,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :user_activity_level

  DEFAULTS = [DEBUG, ERROR, INFO, NOTHING, WARN].freeze

  def self.ensure_defaults!
    return if DEFAULTS.blank?

    existing_ids = where(id: DEFAULTS).pluck(:id)
    missing_ids = DEFAULTS - existing_ids
    return if missing_ids.empty?

    if defined?(Prosopite)
      Prosopite.pause { missing_ids.each { |id| create!(id: id) } }
    else
      missing_ids.each { |id| create!(id: id) }
    end
  end
end
