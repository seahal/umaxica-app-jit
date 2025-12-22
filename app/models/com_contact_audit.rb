class ComContactAudit < GuestsRecord
  belongs_to :com_contact
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :com_contact_audit_event,
             class_name: "ComContactAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :com_contact_audits

  # This model tracks the audit/history of contact interactions
end
