# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_levels
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AppDocumentAuditLevel < AuditRecord
  include StringPrimaryKey

  has_many :app_document_audits, dependent: :restrict_with_error, inverse_of: :app_document_audit_level
end
