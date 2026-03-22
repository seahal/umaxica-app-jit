# frozen_string_literal: true

class MigrateUserTokenKindsToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      add_column(:user_token_kinds, :id_small, :integer, limit: 2)

      # Ensure required values exist
      %w(BROWSER_WEB CLIENT_IOS CLIENT_ANDROID).each do |val|
        execute("INSERT INTO user_token_kinds (id) VALUES ('#{val}') ON CONFLICT (id) DO NOTHING")
      end

      # Mapping
      mapping = {
        "BROWSER_WEB" => 1,
        "CLIENT_IOS" => 2,
        "CLIENT_ANDROID" => 3,
      }

      # Backfill Fixed
      mapping.each do |str, int|
        execute("UPDATE user_token_kinds SET id_small = #{int} WHERE id = '#{str}'")
      end
      execute("UPDATE user_token_kinds SET id_small = 0 WHERE id IN ('NEYO', '')")

      # Backfill Others (start from 4)
      execute(<<~SQL.squish)
        WITH numbered AS (
          SELECT id, ROW_NUMBER() OVER (ORDER BY id) + 3 AS rn
          FROM user_token_kinds
          WHERE id_small IS NULL
        )
        UPDATE user_token_kinds
        SET id_small = numbered.rn
        FROM numbered
        WHERE user_token_kinds.id = numbered.id
      SQL

      change_column_null(:user_token_kinds, :id_small, false, 0)

      # Drop old PK + dependent FKs
      execute("ALTER TABLE user_token_kinds DROP CONSTRAINT user_token_kinds_pkey CASCADE")

      rename_column(:user_token_kinds, :id, :id_old_string)

      rename_column(:user_token_kinds, :id_small, :id)

      execute("ALTER TABLE user_token_kinds ADD PRIMARY KEY (id)")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
