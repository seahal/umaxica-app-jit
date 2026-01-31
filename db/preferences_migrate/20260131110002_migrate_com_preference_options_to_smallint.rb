# frozen_string_literal: true

class MigrateComPreferenceOptionsToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      tables = %w(
        com_preference_colortheme_options
        com_preference_language_options
        com_preference_region_options
        com_preference_timezone_options
      )

      tables.each do |table|
        add_column table, :id_small, :integer, limit: 2
        execute "UPDATE #{table} SET id_small = position"
        execute "ALTER TABLE #{table} DROP CONSTRAINT #{table}_pkey CASCADE"
        rename_column table, :id, :id_old
        rename_column table, :id_small, :id
        execute "ALTER TABLE #{table} ADD PRIMARY KEY (id)"
        change_column_null table, :id, false
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
