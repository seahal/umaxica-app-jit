# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_events
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#

class AppDocumentAuditEvent < AuditRecord
  include StringPrimaryKey

  # Placeholder for audit event types; ids are string tokens (e.g., 'CREATED')
  has_many :app_document_audits,
           class_name: "AppDocumentAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_document_audit_event,
           dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
  before_validation { self.id = id&.upcase }
end
