# rubocop:disable Rails/CreateTableWithTimestamps
class CreateAppTimelineAuditEvents < ActiveRecord::Migration[8.2]
  def up
    create_table :app_timeline_audit_events, id: :string, limit: 255

    execute "ALTER TABLE app_timeline_audit_events ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :app_timeline_audit_events
  end
end

# rubocop:enable Rails/CreateTableWithTimestamps
