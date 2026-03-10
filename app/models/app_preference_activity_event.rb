# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_preference_activity_events
# Database name: activity
#
#  id :bigint           not null, primary key
#
class AppPreferenceActivityEvent < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  REFRESH_TOKEN_ROTATED = 1
  UPDATE_PREFERENCE_COOKIE = 2
  UPDATE_PREFERENCE_COLORTHEME = 3
  RESET_BY_USER_DECISION = 4
  UPDATE_PREFERENCE_TIMEZONE = 5
  UPDATE_PREFERENCE_REGION = 6
  UPDATE_PREFERENCE_LANGUAGE = 7
  CREATE_NEW_PREFERENCE_TOKEN = 8

  # Placeholder for audit event types; ids are string tokens (e.g., 'CREATED')
  has_many :app_preference_activities,
           class_name: "AppPreferenceActivity",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_preference_activity_event,
           dependent: :restrict_with_error

  DEFAULTS = [
    REFRESH_TOKEN_ROTATED,
    UPDATE_PREFERENCE_COOKIE,
    UPDATE_PREFERENCE_COLORTHEME,
    RESET_BY_USER_DECISION,
    UPDATE_PREFERENCE_TIMEZONE,
    UPDATE_PREFERENCE_REGION,
    UPDATE_PREFERENCE_LANGUAGE,
    CREATE_NEW_PREFERENCE_TOKEN,
  ].freeze

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
