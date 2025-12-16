# frozen_string_literal: true

class OrgContactAuditEvent < GuestsRecord
  include UppercaseIdValidation

  self.table_name = "org_contact_audit_events"

  has_many :org_contact_audits,
           class_name: "OrgContactAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_contact_audit_event,
           dependent: :restrict_with_exception
end
