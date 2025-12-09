class AppDocumentAuditEvent < BusinessesRecord
  self.table_name = "app_document_audit_events"

  # Placeholder for audit event types; ids are string tokens (e.g., 'CREATED')
  has_many :app_document_audits,
           class_name: "AppDocumentAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_document_audit_event,
           dependent: :restrict_with_exception
end
