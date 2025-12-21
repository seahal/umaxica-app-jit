# rubocop:disable Rails/CreateTableWithTimestamps
class CreateComDocumentAuditEvents < ActiveRecord::Migration[8.2]
  def up
    create_table :com_document_audit_events, id: :string, limit: 255

    execute "ALTER TABLE com_document_audit_events ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :com_document_audit_events
  end
end

# rubocop:enable Rails/CreateTableWithTimestamps
