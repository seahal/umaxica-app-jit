# rubocop:disable Rails/CreateTableWithTimestamps
class CreateOrgTimelineStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :org_timeline_statuses, id: :string, limit: 255

    execute "ALTER TABLE org_timeline_statuses ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :org_timeline_statuses
  end
end

# rubocop:enable Rails/CreateTableWithTimestamps
