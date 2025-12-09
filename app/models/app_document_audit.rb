class AppDocumentAudit < BusinessesRecord
  self.table_name = "app_document_audits"

  belongs_to :app_document

  # event_id references AppDocumentAuditEvent.id (string)
  belongs_to :app_document_audit_event,
             class_name: "AppDocumentAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :app_document_audits
end
