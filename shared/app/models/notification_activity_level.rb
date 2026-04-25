# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
class NotificationActivityLevel < ActivityRecord
  self.record_timestamps = false
  NOTHING = 0

  has_many :notification_activities,
           dependent: :restrict_with_error,
           inverse_of: :notification_activity_level

  DEFAULTS = [NOTHING].freeze

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
