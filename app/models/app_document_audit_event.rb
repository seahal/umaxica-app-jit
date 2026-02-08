# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

class AppDocumentAuditEvent < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  CREATED = 1

  # Placeholder for audit event types; ids are integer constants (e.g., CREATED = 1)
  has_many :app_document_audits,
           class_name: "AppDocumentAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_document_audit_event,
           dependent: :restrict_with_error
end
