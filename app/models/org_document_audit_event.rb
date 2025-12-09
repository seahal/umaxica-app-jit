class OrgDocumentAuditEvent < BusinessesRecord
  self.table_name = "org_document_audit_events"

  has_many :org_document_audits,
           class_name: "OrgDocumentAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_document_audit_event,
           dependent: :restrict_with_exception
end
