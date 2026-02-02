# frozen_string_literal: true

class FixComContactStatusFkNullify < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # com_contacts.status_id -> com_contact_statuses with ON DELETE SET NULL
      replace_fk_with_nullify(:com_contacts, :com_contact_statuses, :status_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def replace_fk_with_nullify(from_table, to_table, column)
    return unless table_exists?(from_table) && table_exists?(to_table)
    return unless column_exists?(from_table, column)

    # Find and drop existing FK
    fk_rows = connection.select_all(<<~SQL.squish)
      SELECT conname FROM pg_constraint#{" "}
      WHERE conrelid = '#{from_table}'::regclass#{" "}
        AND confrelid = '#{to_table}'::regclass
    SQL

    fk_rows.each do |row|
      execute "ALTER TABLE #{from_table} DROP CONSTRAINT #{row["conname"]}"
    end

    # Add new FK with ON DELETE SET NULL
    fk_name = "fk_#{from_table}_on_#{column}_nullify"
    execute <<~SQL.squish
      ALTER TABLE #{from_table}#{" "}
      ADD CONSTRAINT #{fk_name}#{" "}
      FOREIGN KEY (#{column}) REFERENCES #{to_table} (id)#{" "}
      ON DELETE SET NULL
    SQL

    Rails.logger.debug { "Added FK with nullify: #{from_table}.#{column} -> #{to_table}" }
  rescue => e
    Rails.logger.debug { "Warning: #{e.message}" }
  end
end
