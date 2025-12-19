# rubocop:disable Rails/CreateTableWithTimestamps
class CreateComTimelineStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :com_timeline_statuses, id: :string, limit: 255

    execute "ALTER TABLE com_timeline_statuses ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :com_timeline_statuses
  end
end

# rubocop:enable Rails/CreateTableWithTimestamps
