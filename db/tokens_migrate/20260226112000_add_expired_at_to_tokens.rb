# frozen_string_literal: true

class AddExpiredAtToTokens < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    add_expired_at_column(:user_tokens)
    add_expired_at_column(:staff_tokens)
  end

  def down
    remove_index :user_tokens, :expired_at, algorithm: :concurrently if index_exists?(:user_tokens, :expired_at)
    remove_index :staff_tokens, :expired_at, algorithm: :concurrently if index_exists?(:staff_tokens, :expired_at)

    remove_column :user_tokens, :expired_at if column_exists?(:user_tokens, :expired_at)
    remove_column :staff_tokens, :expired_at if column_exists?(:staff_tokens, :expired_at)
  end

  private

  def add_expired_at_column(table)
    add_column table, :expired_at, :datetime unless column_exists?(table, :expired_at)

    safety_assured do
      execute <<~SQL.squish
        UPDATE #{table}
        SET expired_at = revoked_at
        WHERE revoked_at IS NOT NULL AND expired_at IS NULL
      SQL
    end

    add_index table, :expired_at, algorithm: :concurrently unless index_exists?(table, :expired_at)
  end
end
