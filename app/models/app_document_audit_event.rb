# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_events
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_app_document_audit_events_on_code  (code) UNIQUE
#

class AppDocumentAuditEvent < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  # Placeholder for audit event types; ids are string tokens (e.g., 'CREATED')
  has_many :app_document_audits,
           class_name: "AppDocumentAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_document_audit_event,
           dependent: :restrict_with_error

  before_validation { self.id = id&.upcase }
end
