# frozen_string_literal: true

class RenameOccurrenceExpiryToRevocation < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %i(
    area_occurrences
    domain_occurrences
    email_occurrences
    ip_occurrences
    jwt_occurrences
    staff_occurrences
    telephone_occurrences
    user_occurrences
    zip_occurrences
  ).freeze

  def up
    TABLES.each do |table|
      safety_assured do
        rename_column(table, :expires_at, :revoked_at) if column_exists?(table, :expires_at)
      end

      rename_index_if_exists(table, "index_#{table}_on_expires_at", "index_#{table}_on_revoked_at")

      safety_assured do
        change_column_default(table, :revoked_at, -> { "'infinity'" })

        execute(<<~SQL.squish)
          UPDATE #{table}
          SET revoked_at = 'infinity'
        SQL

        change_column_null(table, :revoked_at, false)
      end

      next if column_exists?(table, :deletable_at)

      safety_assured do
        add_column(table, :deletable_at, :timestamptz, null: false, default: -> { "'infinity'" })
      end

      add_index(table, :deletable_at, algorithm: :concurrently) unless index_exists?(table, :deletable_at)
    end
  end

  def down
    TABLES.each do |table|
      if column_exists?(table, :deletable_at)
        remove_index(table, :deletable_at, algorithm: :concurrently) if index_exists?(table, :deletable_at)
        remove_column(table, :deletable_at)
      end

      safety_assured do
        change_column_default(table, :revoked_at, -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" })
      end
      rename_index_if_exists(table, "index_#{table}_on_revoked_at", "index_#{table}_on_expires_at")
      safety_assured do
        rename_column(table, :revoked_at, :expires_at) if column_exists?(table, :revoked_at)
      end
    end
  end

  private

  def rename_index_if_exists(table, old_name, new_name)
    return unless index_name_exists?(table, old_name)
    return if index_name_exists?(table, new_name)

    rename_index(table, old_name, new_name)
  end
end
