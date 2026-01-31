# frozen_string_literal: true

class MigrateStaffTokenKindsToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # 1. Add new column
      add_column :staff_token_kinds, :id_small, :integer, limit: 2

      # Ensure required values exist (Method B: Fixed Mapping)
      # BROWSER_WEB is default for staff_tokens.staff_token_kind_id
      %w(BROWSER_WEB CLIENT_IOS CLIENT_ANDROID).each do |val|
        execute("INSERT INTO staff_token_kinds (id) VALUES ('#{val}') ON CONFLICT (id) DO NOTHING")
      end

      # Mapping
      mapping = {
        "BROWSER_WEB" => 1,
        "CLIENT_IOS" => 2,
        "CLIENT_ANDROID" => 3,
        # 0 is reserved for NEYO/Empty
      }

      # Backfill Fixed
      mapping.each do |str, int|
        execute("UPDATE staff_token_kinds SET id_small = #{int} WHERE id = '#{str}'")
      end
      execute("UPDATE staff_token_kinds SET id_small = 0 WHERE id IN ('NEYO', '')")

      # Backfill Others (start from 4)
      execute <<~SQL.squish
        WITH numbered AS (
          SELECT id, ROW_NUMBER() OVER (ORDER BY id) + 3 AS rn
          FROM staff_token_kinds
          WHERE id_small IS NULL
        )
        UPDATE staff_token_kinds
        SET id_small = numbered.rn
        FROM numbered
        WHERE staff_token_kinds.id = numbered.id
      SQL

      change_column_null :staff_token_kinds, :id_small, false, 0

      # Drop old FKs depending on this PK
      # Typically staff_tokens(staff_token_kind_id)
      # We use CASCADE to drop the FK constraint automatically
      execute "ALTER TABLE staff_token_kinds DROP CONSTRAINT staff_token_kinds_pkey CASCADE"

      # Rename old string ID for migration use in Step 2
      rename_column :staff_token_kinds, :id, :id_old_string

      # Promote smallint to ID
      rename_column :staff_token_kinds, :id_small, :id
      execute "ALTER TABLE staff_token_kinds ADD PRIMARY KEY (id)"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
