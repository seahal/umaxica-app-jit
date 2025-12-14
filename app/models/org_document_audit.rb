# frozen_string_literal: true

class OrgDocumentAudit < BusinessesRecord
  self.table_name = "org_document_audits"

  belongs_to :org_document

  belongs_to :org_document_audit_event,
             class_name: "OrgDocumentAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :org_document_audits
end
