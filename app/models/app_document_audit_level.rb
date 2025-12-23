class AppDocumentAuditLevel < BusinessesRecord
  include UppercaseId

  has_many :app_document_audits, dependent: :restrict_with_error, inverse_of: :app_document_audit_level
end
