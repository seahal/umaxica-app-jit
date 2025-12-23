class ComDocumentAuditLevel < BusinessesRecord
  include UppercaseId

  has_many :com_document_audits, dependent: :restrict_with_error, inverse_of: :com_document_audit_level
end
