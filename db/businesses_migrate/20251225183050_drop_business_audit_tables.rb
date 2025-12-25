# frozen_string_literal: true

class DropBusinessAuditTables < ActiveRecord::Migration[8.2]
  def up
    # Drop App Document Audit tables
    drop_table :app_document_audits if table_exists?(:app_document_audits)
    drop_table :app_document_audit_events if table_exists?(:app_document_audit_events)
    drop_table :app_document_audit_levels if table_exists?(:app_document_audit_levels)

    # Drop App Timeline Audit tables
    drop_table :app_timeline_audits if table_exists?(:app_timeline_audits)
    drop_table :app_timeline_audit_events if table_exists?(:app_timeline_audit_events)
    drop_table :app_timeline_audit_levels if table_exists?(:app_timeline_audit_levels)

    # Drop Com Document Audit tables
    drop_table :com_document_audits if table_exists?(:com_document_audits)
    drop_table :com_document_audit_events if table_exists?(:com_document_audit_events)
    drop_table :com_document_audit_levels if table_exists?(:com_document_audit_levels)

    # Drop Com Timeline Audit tables
    drop_table :com_timeline_audits if table_exists?(:com_timeline_audits)
    drop_table :com_timeline_audit_events if table_exists?(:com_timeline_audit_events)
    drop_table :com_timeline_audit_levels if table_exists?(:com_timeline_audit_levels)

    # Drop Org Document Audit tables
    drop_table :org_document_audits if table_exists?(:org_document_audits)
    drop_table :org_document_audit_events if table_exists?(:org_document_audit_events)
    drop_table :org_document_audit_levels if table_exists?(:org_document_audit_levels)

    # Drop Org Timeline Audit tables
    drop_table :org_timeline_audits if table_exists?(:org_timeline_audits)
    drop_table :org_timeline_audit_events if table_exists?(:org_timeline_audit_events)
    drop_table :org_timeline_audit_levels if table_exists?(:org_timeline_audit_levels)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot restore dropped audit tables"
  end
end
