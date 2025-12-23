# rubocop:disable Rails/CreateTableWithTimestamps
class CreateStaffOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :staff_occurrence_statuses, id: :string, limit: 255

    execute "ALTER TABLE staff_occurrence_statuses ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :staff_occurrence_statuses
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
