# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_activity_events
# Database name: activity
#
#  id :bigint           not null, primary key
#
class UserActivityEvent < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  ACCOUNT_RECOVERED = 1
  ACCOUNT_WITHDRAWN = 2
  AUTHORIZATION_FAILED = 3
  LOGGED_IN = 4
  LOGGED_OUT = 5
  LOGIN_FAILED = 6
  LOGIN_SUCCESS = 7
  LOGOUT = 8
  NEYO = 9
  NON_EXISTENT_EVENT = 10
  PASSKEY_REGISTERED = 11
  PASSKEY_REMOVED = 12
  RECOVERY_CODES_GENERATED = 13
  RECOVERY_CODE_USED = 14
  SIGNED_UP_WITH_APPLE = 15
  SIGNED_UP_WITH_EMAIL = 16
  SIGNED_UP_WITH_GOOGLE = 17
  SIGNED_UP_WITH_TELEPHONE = 18
  TOKEN_REFRESHED = 19
  TOTP_DISABLED = 20
  TOTP_ENABLED = 21
  USER_SECRET_CREATED = 22
  USER_SECRET_REMOVED = 23
  USER_SECRET_UPDATED = 24
  EMAIL_REMOVED = 25
  TELEPHONE_REMOVED = 26
  SOCIAL_UNLINKED = 27
  STEP_UP_VERIFIED = 28

  # Association with user_activities
  has_many :user_activities,
           foreign_key: :event_id,
           dependent: :restrict_with_error,
           inverse_of: :user_activity_event

  scope :ordered, -> { order(:id) }

  DEFAULTS = [
    ACCOUNT_RECOVERED,
    ACCOUNT_WITHDRAWN,
    AUTHORIZATION_FAILED,
    LOGGED_IN,
    LOGGED_OUT,
    LOGIN_FAILED,
    LOGIN_SUCCESS,
    LOGOUT,
    NEYO,
    NON_EXISTENT_EVENT,
    PASSKEY_REGISTERED,
    PASSKEY_REMOVED,
    RECOVERY_CODES_GENERATED,
    RECOVERY_CODE_USED,
    SIGNED_UP_WITH_APPLE,
    SIGNED_UP_WITH_EMAIL,
    SIGNED_UP_WITH_GOOGLE,
    SIGNED_UP_WITH_TELEPHONE,
    TOKEN_REFRESHED,
    TOTP_DISABLED,
    TOTP_ENABLED,
    USER_SECRET_CREATED,
    USER_SECRET_REMOVED,
    USER_SECRET_UPDATED,
    EMAIL_REMOVED,
    TELEPHONE_REMOVED,
    SOCIAL_UNLINKED,
    STEP_UP_VERIFIED,
  ].freeze

  def self.ensure_defaults!
    DEFAULTS.each do |event_id|
      find_or_create_by!(id: event_id)
    end
  end
end
