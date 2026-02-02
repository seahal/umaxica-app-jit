# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_events
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_document_audit_events_on_code  (code) UNIQUE
#

class ComDocumentAuditEvent < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :com_document_audits,
           class_name: "ComDocumentAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_document_audit_event,
           dependent: :restrict_with_error
  before_validation { self.id = id&.upcase }
end
