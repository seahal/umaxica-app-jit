# frozen_string_literal: true

class MigrateOrgPreferenceOptionFksToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      mappings = {
        "org_preference_colorthemes" => "org_preference_colortheme_options",
        "org_preference_languages" => "org_preference_language_options",
        "org_preference_regions" => "org_preference_region_options",
        "org_preference_timezones" => "org_preference_timezone_options",
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
