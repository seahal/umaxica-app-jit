# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_events
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_com_document_audit_events_on_id  (id) UNIQUE
#

class ComDocumentAuditEvent < AuditRecord
  self.record_timestamps = false

  has_many :com_document_audits,
           class_name: "ComDocumentAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_document_audit_event,
           dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
  before_validation { self.id = id&.upcase }
end
