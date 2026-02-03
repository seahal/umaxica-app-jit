# frozen_string_literal: true

# == Schema Information
#
# Table name: user_audit_events
# Database name: audit
#
#  id :bigint           not null, primary key
#
class UserAuditEvent < AuditRecord
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

  # Association with user_audits
  has_many :user_audits,
           foreign_key: :event_id,
           dependent: :restrict_with_error,
           inverse_of: :user_audit_event

  DEFAULTS = [
    LOGGED_IN,
    LOGGED_OUT,
    LOGIN_FAILED,
    TOKEN_REFRESHED,
  ].freeze

  def self.ensure_defaults!
    DEFAULTS.each do |event_id|
      find_or_create_by!(id: event_id)
    end
  end
end
