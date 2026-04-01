# frozen_string_literal: true

class StandardizeTokenDeletableAtToInfinity < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %i(user_tokens staff_tokens).freeze

  def up
    TABLES.each do |table|
      safety_assured do
        execute(<<~SQL.squish)
          UPDATE #{table}
          SET deletable_at = 'infinity'
          WHERE deletable_at IS NULL
        SQL

        change_column_null(table, :deletable_at, false)
      end

      change_column_default(table, :deletable_at, -> { "'infinity'" })
      add_index(table, :deletable_at, algorithm: :concurrently) unless index_exists?(table, :deletable_at)
    end
  end

  def down
    TABLES.each do |table|
      change_column_null(table, :deletable_at, true)
      change_column_default(table, :deletable_at, nil)
    end
  end
end
