# == Schema Information
#
# Table name: com_document_audit_levels
#
#  id         :string           default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ComDocumentAuditLevel < BusinessesRecord
  include UppercaseId

  has_many :com_document_audits, dependent: :restrict_with_error, inverse_of: :com_document_audit_level
end
