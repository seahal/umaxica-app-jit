# frozen_string_literal: true

# == Schema Information
#
# Table name: app_preference_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
class AppPreferenceActivityLevel < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  INFO = 1

  has_many :app_preference_activities, dependent: :restrict_with_error, inverse_of: :app_preference_activity_level
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }

  DEFAULTS = [INFO].freeze

  def self.ensure_defaults!
    DEFAULTS.each { |id| find_or_create_by!(id: id) }
  end
end
