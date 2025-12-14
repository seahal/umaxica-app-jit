# frozen_string_literal: true

class ComContactAudit < GuestsRecord
  # Use existing table `com_contact_histories` for storage to avoid a migration
  # and keep backward compatibility with previously-named table.
  self.table_name = "com_contact_histories"

  belongs_to :com_contact

  # This model tracks the audit/history of contact interactions
end
