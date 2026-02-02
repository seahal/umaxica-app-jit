# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_levels
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_app_document_audit_levels_on_code  (code) UNIQUE
#

class AppDocumentAuditLevel < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :app_document_audits, dependent: :restrict_with_error, inverse_of: :app_document_audit_level
end
