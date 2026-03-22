# frozen_string_literal: true

class EnsureActiveExpiredOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    ensure_statuses(:user_occurrence_statuses)
    ensure_statuses(:staff_occurrence_statuses)
  end

  def down
    # Keep shared reference statuses in place.
  end

  private

  def ensure_statuses(table_name)
    add_column(table_name, :name, :string, null: false, default: "") unless column_exists?(table_name, :name)

    safety_assured do
      execute(<<~SQL.squish)
        INSERT INTO #{table_name} (id, name)
        VALUES (1, 'active'), (2, 'expired')
        ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name
      SQL
    end
  end
end
