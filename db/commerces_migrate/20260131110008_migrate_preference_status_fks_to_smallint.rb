# frozen_string_literal: true

class MigratePreferenceStatusFksToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      mappings = {
        "app_preferences" => "app_preference_statuses",
        "com_preferences" => "com_preference_statuses",
        "org_preferences" => "org_preference_statuses",
      }

      mappings.each do |table, ref_table|
        add_column(table, :status_id_small, :integer, limit: 2, default: 0)

        # Backfill
        execute(<<~SQL.squish)
          UPDATE #{table} t
          SET status_id_small = r.id
          FROM #{ref_table} r
          WHERE t.status_id = r.id_old
        SQL

        # 'NEYO' / '' / NULL -> 0 is already default 0 by add_column

        remove_column(table, :status_id)
        rename_column(table, :status_id_small, :status_id)

        change_column_null(table, :status_id, false)
        change_column_default(table, :status_id, from: nil, to: 0)

        add_index(table, :status_id)
        add_foreign_key(table, ref_table, column: :status_id)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
