# frozen_string_literal: true

# == Schema Information
#
# Table name: app_preference_audit_events
# Database name: audit
#
#  id :bigint           not null, primary key
#
class AppPreferenceAuditEvent < AuditRecord
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
  has_many :app_preference_audits,
           class_name: "AppPreferenceAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_preference_audit_event,
           dependent: :restrict_with_error
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }
end
