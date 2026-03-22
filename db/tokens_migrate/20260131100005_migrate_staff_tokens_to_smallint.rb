# frozen_string_literal: true

class MigrateStaffTokensToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # 1. Add columns
      add_column(:staff_tokens, :staff_token_kind_id_small, :integer, limit: 2, default: 0)
      add_column(:staff_tokens, :staff_token_status_id_small, :integer, limit: 2, default: 0)

      # 2. Backfill Kind
      # Join with ref table on old string id
      execute(<<~SQL.squish)
        UPDATE staff_tokens st
        SET staff_token_kind_id_small = k.id
        FROM staff_token_kinds k
        WHERE st.staff_token_kind_id = k.id_old_string
      SQL
      # Handle Fallback (NULL/Empty -> 0)
      # The default is 0 via add_column, but the UPDATE might have missed some if they didn't match.
      # Those unmatched remain 0 (default).
      # But wait, if add_column default is 0, existing rows get 0 automatically.
      # Then the UPDATE overwrites matches.
      # Correct.

      # 3. Backfill Status
      execute(<<~SQL.squish)
        UPDATE staff_tokens st
        SET staff_token_status_id_small = s.id
        FROM staff_token_statuses s
        WHERE st.staff_token_status_id = s.id_old_string
      SQL
      # Fallback to 0 is handled by default.

      # 4. Remove old constraints/indexes
      # FKs were dropped in Step 1 (CASCADE).
      remove_index(:staff_tokens, :staff_token_kind_id) rescue nil
      remove_index(:staff_tokens, :staff_token_status_id) rescue nil
      execute("ALTER TABLE staff_tokens DROP CONSTRAINT IF EXISTS chk_staff_tokens_staff_token_status_id_format")

      # 5. Drop old columns
      remove_column(:staff_tokens, :staff_token_kind_id)
      remove_column(:staff_tokens, :staff_token_status_id)

      # 6. Rename new columns
      rename_column(:staff_tokens, :staff_token_kind_id_small, :staff_token_kind_id)
      rename_column(:staff_tokens, :staff_token_status_id_small, :staff_token_status_id)

      # 7. Add new Constraints
      change_column_null(:staff_tokens, :staff_token_kind_id, false)
      change_column_null(:staff_tokens, :staff_token_status_id, false)

      # Defaults
      change_column_default(:staff_tokens, :staff_token_kind_id, from: 0, to: 1) # BROWSER_WEB
      change_column_default(:staff_tokens, :staff_token_status_id, from: 0, to: 0) # NEYO

      # FKs
      add_foreign_key(:staff_tokens, :staff_token_kinds)
      add_foreign_key(:staff_tokens, :staff_token_statuses)

      # Indexes
      add_index(:staff_tokens, :staff_token_kind_id)
      add_index(:staff_tokens, :staff_token_status_id)

      # Optional positive check
      execute("ALTER TABLE staff_tokens ADD CONSTRAINT chk_staff_tokens_kind_id_positive CHECK (staff_token_kind_id >= 0)")
      execute("ALTER TABLE staff_tokens ADD CONSTRAINT chk_staff_tokens_status_id_positive CHECK (staff_token_status_id >= 0)")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
