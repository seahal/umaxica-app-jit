# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_levels
# Database name: audit
#
#  id :bigint           not null, primary key
#

class ComDocumentAuditLevel < AuditRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NEYO = 1

  has_many :com_document_audits, dependent: :restrict_with_error, inverse_of: :com_document_audit_level
end
