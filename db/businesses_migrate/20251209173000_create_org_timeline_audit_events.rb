# rubocop:disable Rails/CreateTableWithTimestamps
class CreateOrgTimelineAuditEvents < ActiveRecord::Migration[8.2]
  def up
    create_table :org_timeline_audit_events, id: :string, limit: 255

    execute "ALTER TABLE org_timeline_audit_events ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :org_timeline_audit_events
  end
end

# rubocop:enable Rails/CreateTableWithTimestamps
