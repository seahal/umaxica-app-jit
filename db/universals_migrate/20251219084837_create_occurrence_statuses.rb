# rubocop:disable Rails/CreateTableWithTimestamps
class CreateOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :occurrence_statuses, id: :string, limit: 255

    execute "ALTER TABLE occurrence_statuses ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :occurrence_statuses
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
