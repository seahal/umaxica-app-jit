# frozen_string_literal: true

class MigrateUserTokenStatusesToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      add_column(:user_token_statuses, :id_small, :integer, limit: 2)

      # Ensure required
      %w(ACTIVE).each do |val|
        execute("INSERT INTO user_token_statuses (id) VALUES ('#{val}') ON CONFLICT (id) DO NOTHING")
      end

      mapping = {
        "ACTIVE" => 1,
      }

      # Backfill Fixed
      mapping.each do |str, int|
        execute("UPDATE user_token_statuses SET id_small = #{int} WHERE id = '#{str}'")
      end
      execute("UPDATE user_token_statuses SET id_small = 0 WHERE id IN ('NEYO', '')")

      # Backfill Others
      execute(<<~SQL.squish)
        WITH numbered AS (
          SELECT id, ROW_NUMBER() OVER (ORDER BY id) + 1 AS rn
          FROM user_token_statuses
          WHERE id_small IS NULL
        )
        UPDATE user_token_statuses
        SET id_small = numbered.rn
        FROM numbered
        WHERE user_token_statuses.id = numbered.id
      SQL

      change_column_null(:user_token_statuses, :id_small, false, 0)

      execute("ALTER TABLE user_token_statuses DROP CONSTRAINT user_token_statuses_pkey CASCADE")

      execute("DROP INDEX IF EXISTS index_user_token_statuses_on_lower_id")
      execute("ALTER TABLE user_token_statuses DROP CONSTRAINT IF EXISTS chk_user_token_statuses_id_format")

      rename_column(:user_token_statuses, :id, :id_old_string)

      rename_column(:user_token_statuses, :id_small, :id)

      execute("ALTER TABLE user_token_statuses ADD PRIMARY KEY (id)")

      execute("ALTER TABLE user_token_statuses ADD CONSTRAINT chk_user_token_statuses_id_positive CHECK (id >= 0)")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
