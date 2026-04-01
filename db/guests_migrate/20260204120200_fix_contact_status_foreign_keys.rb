# frozen_string_literal: true

class FixContactStatusForeignKeys < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      fix_fk(:app_contacts, :app_contact_statuses, :contact_status_id)
      fix_fk(:com_contacts, :com_contact_statuses, :contact_status_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def fix_fk(from_table, to_table, column)
    return unless table_exists?(from_table) && table_exists?(to_table)
    return unless column_exists?(from_table, column)

    remove_foreign_key(from_table, column: column) if foreign_key_exists?(from_table, column: column)
    add_foreign_key(from_table, to_table, column: column, on_delete: :restrict)
  end
end
