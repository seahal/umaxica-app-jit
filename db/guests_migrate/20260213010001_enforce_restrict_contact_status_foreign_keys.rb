# frozen_string_literal: true

class EnforceRestrictContactStatusForeignKeys < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      replace_status_fk(:app_contacts, :app_contact_statuses)
      replace_status_fk(:com_contacts, :com_contact_statuses)
    end
  end

  def down
    safety_assured do
      replace_status_fk(:app_contacts, :app_contact_statuses, on_delete: :nullify)
      replace_status_fk(:com_contacts, :com_contact_statuses, on_delete: :nullify)
    end
  end

  private

  def replace_status_fk(from_table, to_table, on_delete: :restrict)
    return unless table_exists?(from_table) && table_exists?(to_table)
    return unless column_exists?(from_table, :status_id)

    remove_foreign_key from_table, column: :status_id if foreign_key_exists?(from_table, column: :status_id)
    add_foreign_key from_table, to_table, column: :status_id, on_delete: on_delete
  end
end
