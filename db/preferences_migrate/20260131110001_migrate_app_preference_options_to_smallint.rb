# frozen_string_literal: true

class MigrateAppPreferenceOptionsToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      tables = %w(
        app_preference_colortheme_options
        app_preference_language_options
        app_preference_region_options
        app_preference_timezone_options
      )

      tables.each do |table|
        # 1. Add id_small
        add_column table, :id_small, :integer, limit: 2

        # 2. Backfill: id_small = position
        execute "UPDATE #{table} SET id_small = position"

        # 3. Drop existing FKs depending on this PK
        # We'll drop constraint by name if possible, but finding the FK name is tricky.
        # However, ActiveRecord CASCADE should handle it on DB level if we use ALTER TABLE ... DROP CONSTRAINT ... CASCADE
        execute "ALTER TABLE #{table} DROP CONSTRAINT #{table}_pkey CASCADE"

        # 4. Rename old id and promote id_small
        rename_column table, :id, :id_old
        # rubocop:disable Rails/DangerousColumnNames
        rename_column table, :id_small, :id
        # rubocop:enable Rails/DangerousColumnNames

        # 5. Set PK
        execute "ALTER TABLE #{table} ADD PRIMARY KEY (id)"

        # 6. Null constraint
        change_column_null table, :id, false
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
