# frozen_string_literal: true

class AddDeletableAtToTokens < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %i(user_tokens staff_tokens).freeze

  def up
    TABLES.each do |table|
      add_column(table, :deletable_at, :datetime)

      safety_assured do
        execute(<<~SQL.squish)
          UPDATE #{table}
          SET deletable_at = refresh_expires_at
        SQL
      end

      safety_assured do
        change_column_null(table, :deletable_at, false)
      end
      add_index(table, :deletable_at, algorithm: :concurrently)
    end
  end

  def down
    TABLES.each do |table|
      remove_index(table, :deletable_at, algorithm: :concurrently)
      remove_column(table, :deletable_at)
    end
  end
end
