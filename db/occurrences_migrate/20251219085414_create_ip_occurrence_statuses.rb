# frozen_string_literal: true

# rubocop:disable Rails/CreateTableWithTimestamps
class CreateIpOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :ip_occurrence_statuses, id: :string, limit: 255

    execute "ALTER TABLE ip_occurrence_statuses ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :ip_occurrence_statuses
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
