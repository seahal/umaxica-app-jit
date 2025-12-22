class OrgContactAudit < GuestsRecord
  # Use existing table `org_contact_histories` for storage to avoid a migration
  # and keep backward compatibility with previously-named table.
  self.table_name = "org_contact_histories"

  belongs_to :org_contact
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :org_contact_audit_event,
             class_name: "OrgContactAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :org_contact_audits

  # This model tracks the audit/history of contact interactions
end
