# frozen_string_literal: true

class MigrateComPreferenceOptionFksToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      mappings = {
        "com_preference_colorthemes" => "com_preference_colortheme_options",
        "com_preference_languages" => "com_preference_language_options",
        "com_preference_regions" => "com_preference_region_options",
        "com_preference_timezones" => "com_preference_timezone_options",
      }

      mappings.each do |table, ref_table|
        add_column(table, :option_id_small, :integer, limit: 2)
        execute(<<~SQL.squish)
          UPDATE #{table} t
          SET option_id_small = r.id
          FROM #{ref_table} r
          WHERE t.option_id = r.id_old
        SQL
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
