# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_audit_levels
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_org_document_audit_levels_on_id  (id) UNIQUE
#

class OrgDocumentAuditLevel < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :org_document_audits, dependent: :restrict_with_error, inverse_of: :org_document_audit_level
end
