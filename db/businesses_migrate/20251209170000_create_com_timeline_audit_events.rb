# rubocop:disable Rails/CreateTableWithTimestamps
class CreateComTimelineAuditEvents < ActiveRecord::Migration[8.2]
  def up
    create_table :com_timeline_audit_events, id: :string, limit: 255

    execute "ALTER TABLE com_timeline_audit_events ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :com_timeline_audit_events
  end
end

# rubocop:enable Rails/CreateTableWithTimestamps
