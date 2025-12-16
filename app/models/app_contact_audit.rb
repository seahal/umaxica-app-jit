# frozen_string_literal: true

class AppContactAudit < GuestsRecord
  # Use existing table `app_contact_histories` for storage to avoid a migration
  # and keep backward compatibility with previously-named table.
  self.table_name = "app_contact_histories"

  belongs_to :app_contact
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :app_contact_audit_event,
             class_name: "AppContactAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :app_contact_audits

  # This model tracks the audit/history of contact interactions
end
