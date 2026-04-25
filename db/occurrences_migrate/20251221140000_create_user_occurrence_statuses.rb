# frozen_string_literal: true

class CreateUserOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table(:user_occurrence_statuses, id: :string, limit: 255)

    safety_assured do
      execute("ALTER TABLE user_occurrence_statuses ALTER COLUMN id SET DEFAULT 'NONE'")
    end
  end

  def down
    drop_table(:user_occurrence_statuses)
  end
end
