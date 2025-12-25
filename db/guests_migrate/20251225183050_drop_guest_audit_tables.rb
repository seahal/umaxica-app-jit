# frozen_string_literal: true

class DropGuestAuditTables < ActiveRecord::Migration[8.2]
  def up
    # Drop App Contact Audit tables (uses app_contact_histories table name)
    drop_table :app_contact_histories, force: :cascade if table_exists?(:app_contact_histories)
    drop_table :app_contact_audit_events, force: :cascade if table_exists?(:app_contact_audit_events)
    drop_table :app_contact_audit_levels, force: :cascade if table_exists?(:app_contact_audit_levels)

    # Drop Com Contact Audit tables (uses com_contact_histories table name)
    drop_table :com_contact_histories, force: :cascade if table_exists?(:com_contact_histories)
    drop_table :com_contact_audit_events, force: :cascade if table_exists?(:com_contact_audit_events)
    drop_table :com_contact_audit_levels, force: :cascade if table_exists?(:com_contact_audit_levels)

    # Drop Org Contact Audit tables (uses org_contact_histories table name)
    drop_table :org_contact_histories, force: :cascade if table_exists?(:org_contact_histories)
    drop_table :org_contact_audit_events, force: :cascade if table_exists?(:org_contact_audit_events)
    drop_table :org_contact_audit_levels, force: :cascade if table_exists?(:org_contact_audit_levels)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot restore dropped audit tables"
  end
end
