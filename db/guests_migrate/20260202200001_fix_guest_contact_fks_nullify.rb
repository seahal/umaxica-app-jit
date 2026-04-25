# frozen_string_literal: true

class FixGuestContactFksNullify < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # org_contacts.contact_status_id -> org_contact_statuses with ON DELETE SET NULL
      add_fk_with_nullify(:org_contacts, :org_contact_statuses, :contact_status_id)

      # com_contacts.contact_status_id -> com_contact_statuses with ON DELETE SET NULL
      add_fk_with_nullify(:com_contacts, :com_contact_statuses, :contact_status_id)

      # app_contacts.contact_status_id -> app_contact_statuses with ON DELETE SET NULL
      add_fk_with_nullify(:app_contacts, :app_contact_statuses, :contact_status_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def add_fk_with_nullify(from_table, to_table, column)
    return unless table_exists?(from_table) && table_exists?(to_table)
    return unless column_exists?(from_table, column)

    # Drop existing FK
    fk_rows = connection.select_all(<<~SQL.squish)
      SELECT conname FROM pg_constraint#{" "}
      WHERE conrelid = '#{from_table}'::regclass#{" "}
        AND confrelid = '#{to_table}'::regclass
    SQL

    fk_rows.each do |row|
      execute("ALTER TABLE #{from_table} DROP CONSTRAINT #{row["conname"]}")
    end

    # Add FK with ON DELETE SET NULL
    # Note: contact_status_id is string FK to string PK, so this should work
    fk_name = "fk_#{from_table}_on_#{column}_nullify"
    execute(<<~SQL.squish)
      ALTER TABLE #{from_table}#{" "}
      ADD CONSTRAINT #{fk_name}#{" "}
      FOREIGN KEY (#{column}) REFERENCES #{to_table} (id)#{" "}
      ON DELETE SET NULL
    SQL
  rescue => e
    Rails.logger.debug { "Warning: #{e.message}" }
  end
end
