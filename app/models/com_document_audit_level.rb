# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_levels
#
#  id :string(255)      default("NEYO"), not null, primary key
#

class ComDocumentAuditLevel < UniversalRecord
  include UppercaseId

  has_many :com_document_audits, dependent: :restrict_with_error, inverse_of: :com_document_audit_level
end
