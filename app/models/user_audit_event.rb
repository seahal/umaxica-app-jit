# frozen_string_literal: true

# == Schema Information
#
# Table name: user_audit_events
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#
class UserAuditEvent < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  # Association with user_audits
  has_many :user_audits,
           foreign_key: :event_id,
           dependent: :restrict_with_error,
           inverse_of: :user_audit_event

  DEFAULTS = %w(
    LOGGED_IN
    LOGGED_OUT
    LOGIN_FAILED
    TOKEN_REFRESHED
  ).freeze

  def self.ensure_defaults!
    DEFAULTS.each do |event_id|
      find_or_create_by!(id: event_id)
    end
  end
end
