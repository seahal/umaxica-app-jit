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
  scope :ordered, -> { column_names.include?("position") ? order(:position) : all }

  DEFAULTS = [INFO].freeze

  def self.ensure_defaults!
    DEFAULTS.each { |id| find_or_create_by!(id: id) }
  end
end
