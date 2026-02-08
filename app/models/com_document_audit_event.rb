# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

class ComDocumentAuditEvent < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  CREATED = 1

  has_many :com_document_audits,
           class_name: "ComDocumentAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_document_audit_event,
           dependent: :restrict_with_error
end
