# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_audit_events
# Database name: audit
#
#  id :bigint           not null, primary key
#
class OrgPreferenceAuditEvent < AuditRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  CREATE_NEW_PREFERENCE_TOKEN = 1
  REFRESH_TOKEN_ROTATED = 2
  UPDATE_PREFERENCE_COOKIE = 3
  UPDATE_PREFERENCE_LANGUAGE = 4
  UPDATE_PREFERENCE_TIMEZONE = 5
  RESET_BY_USER_DECISION = 6
  UPDATE_PREFERENCE_REGION = 7
  UPDATE_PREFERENCE_COLORTHEME = 8

  # Placeholder for audit event types; ids are string tokens (e.g., 'CREATED')
  has_many :org_preference_audits,
           class_name: "OrgPreferenceAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_preference_audit_event,
           dependent: :restrict_with_error
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }
end
