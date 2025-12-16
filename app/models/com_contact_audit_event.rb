# frozen_string_literal: true

class ComContactAuditEvent < GuestsRecord
  include UppercaseIdValidation

  self.table_name = "com_contact_audit_events"

  has_many :com_contact_audits,
           class_name: "ComContactAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_contact_audit_event,
           dependent: :restrict_with_exception
end
