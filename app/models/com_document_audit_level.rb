# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_levels
#
#  id         :string(255)      default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ComDocumentAuditLevel < UniversalRecord
  include UppercaseId

  has_many :com_document_audits, dependent: :restrict_with_error, inverse_of: :com_document_audit_level
end
