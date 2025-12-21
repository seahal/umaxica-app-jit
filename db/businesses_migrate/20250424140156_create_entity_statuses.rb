# rubocop:disable Rails/CreateTableWithTimestamps
class CreateEntityStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :entity_statuses, id: :string
  end
end

# rubocop:enable Rails/CreateTableWithTimestamps
