# frozen_string_literal: true

# rubocop:disable Rails/CreateTableWithTimestamps
class CreateEmailOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :email_occurrence_statuses, id: :string, limit: 255

    execute "ALTER TABLE email_occurrence_statuses ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :email_occurrence_statuses
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
