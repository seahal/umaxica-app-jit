# == Schema Information
#
# Table name: org_document_audit_levels
#
#  id         :string           default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OrgDocumentAuditLevel < BusinessesRecord
  include UppercaseId

  has_many :org_document_audits, dependent: :restrict_with_error, inverse_of: :org_document_audit_level
end
