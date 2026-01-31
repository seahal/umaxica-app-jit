# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_events
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_app_document_audit_events_on_id  (id) UNIQUE
#

class AppDocumentAuditEvent < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

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
