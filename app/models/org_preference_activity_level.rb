# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
class OrgPreferenceActivityLevel < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  INFO = 1

  has_many :org_preference_activities, dependent: :restrict_with_error, inverse_of: :org_preference_activity_level

  DEFAULTS = [INFO].freeze

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
