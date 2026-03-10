# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_activity_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

class StaffActivityEvent < ActivityRecord
  # Fixed IDs - do not modify these values
  LOGIN_SUCCESS = 1
  AUTHORIZATION_FAILED = 2
  LOGGED_IN = 3
  LOGGED_OUT = 4
  LOGIN_FAILED = 5
  TOKEN_REFRESHED = 6
  NOTHING = 7
  STAFF_SECRET_CREATED = 8
  STAFF_SECRET_REMOVED = 9
  STAFF_SECRET_UPDATED = 10
  STEP_UP_VERIFIED = 11

  # Association with staff_activities
  has_many :staff_activities,
           foreign_key: :event_id,
           dependent: :destroy,
           inverse_of: :staff_activity_event

  DEFAULTS = [
    LOGIN_SUCCESS, AUTHORIZATION_FAILED, LOGGED_IN, LOGGED_OUT, LOGIN_FAILED,
    TOKEN_REFRESHED, NOTHING, STAFF_SECRET_CREATED, STAFF_SECRET_REMOVED,
    STAFF_SECRET_UPDATED, STEP_UP_VERIFIED,
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
