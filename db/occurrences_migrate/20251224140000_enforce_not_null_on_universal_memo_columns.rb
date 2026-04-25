# frozen_string_literal: true

class EnforceNotNullOnUniversalMemoColumns < ActiveRecord::Migration[8.2]
  TABLES = %i[
    area_occurrences
    domain_occurrences
    email_occurrences
    ip_occurrences
    staff_occurrences
    telephone_occurrences
    user_occurrences
    zip_occurrences
  ].freeze

  def up
    TABLES.each do |table|
      safety_assured { execute("UPDATE #{table} SET body = '' WHERE body IS NULL") }
      safety_assured { execute("UPDATE #{table} SET public_id = '' WHERE public_id IS NULL") }
      safety_assured { execute("UPDATE #{table} SET status_id = '' WHERE status_id IS NULL") }

      safety_assured do
        change_column_null(table, :body, false)
        change_column_null(table, :public_id, false)
        change_column_null(table, :status_id, false)
      end
    end
  end

  def down
    TABLES.each do |table|
      safety_assured do
        change_column_null(table, :body, true)
        change_column_null(table, :public_id, true)
        change_column_null(table, :status_id, true)
      end
    end
  end
end
