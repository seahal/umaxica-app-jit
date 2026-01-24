# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_audit_levels
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#

class OrgDocumentAuditLevel < AuditRecord
  include StringPrimaryKey

  has_many :org_document_audits, dependent: :restrict_with_error, inverse_of: :org_document_audit_level
end
