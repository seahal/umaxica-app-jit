# frozen_string_literal: true

# rubocop:disable Rails/CreateTableWithTimestamps
class CreateUserOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :user_occurrence_statuses, id: :string, limit: 255

    execute "ALTER TABLE user_occurrence_statuses ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :user_occurrence_statuses
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
