# frozen_string_literal: true

class ComDocumentAudit < BusinessesRecord
  self.table_name = "com_document_audits"

  belongs_to :com_document
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :com_document_audit_event,
             class_name: "ComDocumentAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :com_document_audits
end
