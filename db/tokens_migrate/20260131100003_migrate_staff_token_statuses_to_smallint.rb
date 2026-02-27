# frozen_string_literal: true

class MigrateStaffTokenStatusesToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      add_column :staff_token_statuses, :id_small, :integer, limit: 2

      # Ensure required values exist
      %w(ACTIVE).each do |val|
        execute("INSERT INTO staff_token_statuses (id) VALUES ('#{val}') ON CONFLICT (id) DO NOTHING")
      end
      # NEYO is usually 0, if it exists mapping handles it. Sentinel "" also 0.

      # Mapping
      mapping = {
        "ACTIVE" => 1,
      }

      # Backfill Fixed
      mapping.each do |str, int|
        execute("UPDATE staff_token_statuses SET id_small = #{int} WHERE id = '#{str}'")
      end
      execute("UPDATE staff_token_statuses SET id_small = 0 WHERE id IN ('NEYO', '')")

      # Backfill Others (start from 2)
      execute <<~SQL.squish
        WITH numbered AS (
          SELECT id, ROW_NUMBER() OVER (ORDER BY id) + 1 AS rn
          FROM staff_token_statuses
          WHERE id_small IS NULL
        )
        UPDATE staff_token_statuses
        SET id_small = numbered.rn
        FROM numbered
        WHERE staff_token_statuses.id = numbered.id
      SQL

      change_column_null :staff_token_statuses, :id_small, false, 0

      # Drop old PK + dependent FKs
      execute "ALTER TABLE staff_token_statuses DROP CONSTRAINT staff_token_statuses_pkey CASCADE"

      # Drop string-specific constraints/indexes
      execute "DROP INDEX IF EXISTS index_staff_token_statuses_on_lower_id"
      execute "ALTER TABLE staff_token_statuses DROP CONSTRAINT IF EXISTS chk_staff_token_statuses_id_format"

      rename_column :staff_token_statuses, :id, :id_old_string
      # rubocop:disable Rails/DangerousColumnNames
      rename_column :staff_token_statuses, :id_small, :id
      # rubocop:enable Rails/DangerousColumnNames
      execute "ALTER TABLE staff_token_statuses ADD PRIMARY KEY (id)"

      # Optional constraint
      execute "ALTER TABLE staff_token_statuses ADD CONSTRAINT chk_staff_token_statuses_id_positive CHECK (id >= 0)"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
