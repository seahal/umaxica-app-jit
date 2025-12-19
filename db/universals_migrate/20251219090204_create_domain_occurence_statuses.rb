# rubocop:disable Rails/CreateTableWithTimestamps
class CreateDomainOccurenceStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :domain_occurence_statuses, id: :string, limit: 255

    execute "ALTER TABLE domain_occurence_statuses ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :domain_occurence_statuses
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
