# frozen_string_literal: true

class MigrateAppPreferenceOptionFksToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # Mapping of table to its reference option table
      mappings = {
        "app_preference_colorthemes" => "app_preference_colortheme_options",
        "app_preference_languages" => "app_preference_language_options",
        "app_preference_regions" => "app_preference_region_options",
        "app_preference_timezones" => "app_preference_timezone_options",
      }

      mappings.each do |table, ref_table|
        add_column(table, :option_id_small, :integer, limit: 2)

        # Backfill
        execute(<<~SQL.squish)
          UPDATE #{table} t
          SET option_id_small = r.id
          FROM #{ref_table} r
          WHERE t.option_id = r.id_old
        SQL

        # NULL/Empty -> 0 (if we want to normalize, but existing schema had it nullable)
        # Let's keep it 0 as sentinel if it was null/empty
        execute("UPDATE #{table} SET option_id_small = 0 WHERE option_id IS NULL OR option_id = ''")

        remove_column(table, :option_id)
        rename_column(table, :option_id_small, :option_id)

        add_index(table, :option_id)
        add_foreign_key(table, ref_table, column: :option_id)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
