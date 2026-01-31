# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_levels
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_app_document_audit_levels_on_id  (id) UNIQUE
#

class AppDocumentAuditLevel < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :app_document_audits, dependent: :restrict_with_error, inverse_of: :app_document_audit_level
end
