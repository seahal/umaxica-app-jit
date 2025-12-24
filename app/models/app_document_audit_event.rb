# == Schema Information
#
# Table name: app_document_audit_events
#
#  id                    :string(255)      default("NONE"), not null, primary key
#  app_document_audit_id :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#
# Indexes
#
#  index_app_document_audit_events_on_app_document_audit_id  (app_document_audit_id)
#

class AppDocumentAuditEvent < BusinessesRecord
  self.table_name = "app_document_audit_events"

  # Placeholder for audit event types; ids are string tokens (e.g., 'CREATED')
  has_many :app_document_audits,
           class_name: "AppDocumentAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_document_audit_event,
           dependent: :restrict_with_error

  before_validation { self.id = id&.upcase }
  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
end
