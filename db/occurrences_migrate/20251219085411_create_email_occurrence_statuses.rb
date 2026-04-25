# frozen_string_literal: true

class CreateEmailOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table(:email_occurrence_statuses, id: :string, limit: 255)

    safety_assured do
      execute("ALTER TABLE email_occurrence_statuses ALTER COLUMN id SET DEFAULT 'NONE'")
    end
  end

  def down
    drop_table(:email_occurrence_statuses)
  end
end
