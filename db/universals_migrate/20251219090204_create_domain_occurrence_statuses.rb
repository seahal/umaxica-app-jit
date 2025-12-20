# rubocop:disable Rails/CreateTableWithTimestamps
class CreateDomainOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :domain_occurrence_statuses, id: :string, limit: 255

    execute "ALTER TABLE domain_occurrence_statuses ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :domain_occurrence_statuses
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
