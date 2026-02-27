# frozen_string_literal: true

class MigrateUserTokensToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # 1. Add columns
      add_column :user_tokens, :user_token_kind_id_small, :integer, limit: 2, default: 0
      add_column :user_tokens, :user_token_status_id_small, :integer, limit: 2, default: 0

      # 2. Backfill
      execute <<~SQL.squish
        UPDATE user_tokens ut
        SET user_token_kind_id_small = k.id
        FROM user_token_kinds k
        WHERE ut.user_token_kind_id = k.id_old_string
      SQL

      execute <<~SQL.squish
        UPDATE user_tokens ut
        SET user_token_status_id_small = s.id
        FROM user_token_statuses s
        WHERE ut.user_token_status_id = s.id_old_string
      SQL

      # 3. Cleanup
      remove_index :user_tokens, :user_token_kind_id rescue nil
      remove_index :user_tokens, :user_token_status_id rescue nil
      execute "ALTER TABLE user_tokens DROP CONSTRAINT IF EXISTS chk_user_tokens_user_token_status_id_format"

      remove_column :user_tokens, :user_token_kind_id
      remove_column :user_tokens, :user_token_status_id

      # 4. Rename
      rename_column :user_tokens, :user_token_kind_id_small, :user_token_kind_id
      rename_column :user_tokens, :user_token_status_id_small, :user_token_status_id

      # 5. Constraints
      change_column_null :user_tokens, :user_token_kind_id, false
      change_column_null :user_tokens, :user_token_status_id, false

      change_column_default :user_tokens, :user_token_kind_id, from: 0, to: 1
      change_column_default :user_tokens, :user_token_status_id, from: 0, to: 0

      add_foreign_key :user_tokens, :user_token_kinds
      add_foreign_key :user_tokens, :user_token_statuses

      add_index :user_tokens, :user_token_kind_id
      add_index :user_tokens, :user_token_status_id

      execute "ALTER TABLE user_tokens ADD CONSTRAINT chk_user_tokens_kind_id_positive CHECK (user_token_kind_id >= 0)"
      execute "ALTER TABLE user_tokens ADD CONSTRAINT chk_user_tokens_status_id_positive CHECK (user_token_status_id >= 0)"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
