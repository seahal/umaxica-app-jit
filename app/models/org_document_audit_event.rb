# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_audit_events
# Database name: audit
#
#  id :bigint           not null, primary key
#

class OrgDocumentAuditEvent < AuditRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  CREATED = 1

  has_many :org_document_audits,
           class_name: "OrgDocumentAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_document_audit_event,
           dependent: :restrict_with_error
end
