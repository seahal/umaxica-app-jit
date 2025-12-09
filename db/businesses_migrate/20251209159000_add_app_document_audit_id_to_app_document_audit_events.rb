class AddAppDocumentAuditIdToAppDocumentAuditEvents < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    return if column_exists?(:app_document_audit_events, :app_document_audit_id)

    add_column :app_document_audit_events, :app_document_audit_id, :uuid
    add_index :app_document_audit_events, :app_document_audit_id

    # Best-effort backfill: link each event to one audit that referenced it.
    execute <<-SQL.squish
      UPDATE app_document_audit_events e
      SET app_document_audit_id = a.id
      FROM app_document_audits a
      WHERE a.event_id = e.id
    SQL
  end

  def down
    remove_index :app_document_audit_events, :app_document_audit_id if index_exists?(:app_document_audit_events, :app_document_audit_id)
    remove_column :app_document_audit_events, :app_document_audit_id if column_exists?(:app_document_audit_events, :app_document_audit_id)
  end
end
