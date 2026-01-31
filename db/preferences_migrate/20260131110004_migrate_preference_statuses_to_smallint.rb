# frozen_string_literal: true

class MigratePreferenceStatusesToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      tables = %w(
        app_preference_statuses
        com_preference_statuses
        org_preference_statuses
      )

      tables.each do |table|
        add_column table, :id_small, :integer, limit: 2

        # NEYO = 0
        execute "UPDATE #{table} SET id_small = 0 WHERE id = 'NEYO'"
        # Else = position
        execute "UPDATE #{table} SET id_small = position WHERE id != 'NEYO'"

        # Drop PK
        execute "ALTER TABLE #{table} DROP CONSTRAINT #{table}_pkey CASCADE"

        # Drop format check
        # Name: app_preference_statuses_id_format_check, etc.
        execute "ALTER TABLE #{table} DROP CONSTRAINT IF EXISTS #{table}_id_format_check"

        rename_column table, :id, :id_old
        rename_column table, :id_small, :id
        execute "ALTER TABLE #{table} ADD PRIMARY KEY (id)"

        change_column_null table, :id, false
        change_column_default table, :id, from: nil, to: 0

        # Add positive check
        execute "ALTER TABLE #{table} ADD CONSTRAINT chk_#{table}_id_positive CHECK (id >= 0)"
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
