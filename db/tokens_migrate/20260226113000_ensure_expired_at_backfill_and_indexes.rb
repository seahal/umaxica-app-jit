# frozen_string_literal: true

class EnsureExpiredAtBackfillAndIndexes < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %i(user_tokens staff_tokens).freeze

  def up
    TABLES.each do |table|
      next unless column_exists?(table, :expired_at)

      safety_assured do
        execute(<<~SQL.squish)
          UPDATE #{table}
          SET expired_at = revoked_at
          WHERE revoked_at IS NOT NULL AND expired_at IS NULL
        SQL
      end

      add_index(table, :expired_at, algorithm: :concurrently) unless index_exists?(table, :expired_at)
    end
  end

  def down
    # Keep indexes for read performance.
  end
end
