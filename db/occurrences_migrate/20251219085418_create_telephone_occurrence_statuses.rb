# frozen_string_literal: true

class CreateTelephoneOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table(:telephone_occurrence_statuses, id: :string, limit: 255)

    safety_assured do
      execute("ALTER TABLE telephone_occurrence_statuses ALTER COLUMN id SET DEFAULT 'NONE'")
    end
  end

  def down
    drop_table(:telephone_occurrence_statuses)
  end
end
