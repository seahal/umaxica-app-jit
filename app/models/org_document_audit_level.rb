class OrgDocumentAuditLevel < BusinessesRecord
  include UppercaseId

  has_many :org_document_audits, dependent: :restrict_with_exception, inverse_of: :org_document_audit_level
end
