class AddRefreshFieldsToTokens < ActiveRecord::Migration[8.2]
  # refresh_token_digest is nullable for migration safety; plan to enforce NOT NULL after backfill.
  def up
    change_table :user_tokens, bulk: true do |t|
      t.datetime :refresh_expires_at
      t.datetime :revoked_at
      t.datetime :rotated_at
      t.datetime :last_used_at
    end

    change_table :staff_tokens, bulk: true do |t|
      t.datetime :refresh_expires_at
      t.datetime :revoked_at
      t.datetime :rotated_at
      t.datetime :last_used_at
    end

    execute <<~SQL.squish
      UPDATE user_tokens
      SET refresh_expires_at = NOW() + INTERVAL '1 year'
      WHERE refresh_expires_at IS NULL
    SQL

    execute <<~SQL.squish
      UPDATE staff_tokens
      SET refresh_expires_at = NOW() + INTERVAL '1 year'
      WHERE refresh_expires_at IS NULL
    SQL

    change_column_null :user_tokens, :refresh_expires_at, false
    change_column_null :staff_tokens, :refresh_expires_at, false

    change_column_null :user_tokens, :refresh_token_digest, true if column_exists?(:user_tokens, :refresh_token_digest)
    change_column_null :staff_tokens, :refresh_token_digest, true if column_exists?(:staff_tokens, :refresh_token_digest)

    remove_index :user_tokens, :refresh_token_digest if index_exists?(:user_tokens, :refresh_token_digest)
    remove_index :staff_tokens, :refresh_token_digest if index_exists?(:staff_tokens, :refresh_token_digest)

    add_index :user_tokens, :refresh_expires_at
    add_index :user_tokens, :revoked_at
    add_index :staff_tokens, :refresh_expires_at
    add_index :staff_tokens, :revoked_at
  end

  def down
    remove_index :user_tokens, :refresh_expires_at if index_exists?(:user_tokens, :refresh_expires_at)
    remove_index :user_tokens, :revoked_at if index_exists?(:user_tokens, :revoked_at)
    remove_index :staff_tokens, :refresh_expires_at if index_exists?(:staff_tokens, :refresh_expires_at)
    remove_index :staff_tokens, :revoked_at if index_exists?(:staff_tokens, :revoked_at)

    change_table :user_tokens, bulk: true do |t|
      t.remove :refresh_expires_at
      t.remove :revoked_at
      t.remove :rotated_at
      t.remove :last_used_at
    end

    change_table :staff_tokens, bulk: true do |t|
      t.remove :refresh_expires_at
      t.remove :revoked_at
      t.remove :rotated_at
      t.remove :last_used_at
    end

    add_index :user_tokens, :refresh_token_digest, unique: true unless index_exists?(:user_tokens, :refresh_token_digest)
    add_index :staff_tokens, :refresh_token_digest, unique: true unless index_exists?(:staff_tokens, :refresh_token_digest)

    change_column_null :user_tokens, :refresh_token_digest, false if column_exists?(:user_tokens, :refresh_token_digest)
    change_column_null :staff_tokens, :refresh_token_digest, false if column_exists?(:staff_tokens, :refresh_token_digest)
  end
end
