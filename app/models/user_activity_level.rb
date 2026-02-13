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
  NEYO = 4
  WARN = 5

  has_many :user_activities,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :user_activity_level

  scope :ordered, -> { order(:id) }

  DEFAULTS = [DEBUG, ERROR, INFO, NEYO, WARN].freeze

  def self.ensure_defaults!
    DEFAULTS.each do |id|
      find_or_create_by!(id: id)
    end
  end
end
