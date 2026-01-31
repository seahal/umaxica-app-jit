# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_levels
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#

class AppDocumentAuditLevel < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :app_document_audits, dependent: :restrict_with_error, inverse_of: :app_document_audit_level
end
