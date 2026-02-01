# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_levels
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_com_document_audit_levels_on_id  (id) UNIQUE
#

class ComDocumentAuditLevel < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :com_document_audits, dependent: :restrict_with_error, inverse_of: :com_document_audit_level
end
