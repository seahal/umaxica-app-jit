# frozen_string_literal: true

class ValidateNotNullGuestContactStatuses < ActiveRecord::Migration[8.2]
  def up
    apply_not_null(:org_contacts, :contact_status_id, "org_contacts_contact_status_id_null")
    apply_not_null(:com_contacts, :contact_status_id, "com_contacts_contact_status_id_null")
    apply_not_null(:app_contacts, :contact_status_id, "app_contacts_contact_status_id_null")
  end

  def down
    remove_not_null(:org_contacts, :contact_status_id, "org_contacts_contact_status_id_null")
    remove_not_null(:com_contacts, :contact_status_id, "com_contacts_contact_status_id_null")
    remove_not_null(:app_contacts, :contact_status_id, "app_contacts_contact_status_id_null")
  end

  private

  def apply_not_null(table, column, name)
    return unless table_exists?(table) && column_exists?(table, column)

    validate_check_constraint table, name: name
    change_column_null table, column, false
    remove_check_constraint table, name: name
  end

  def remove_not_null(table, column, name)
    return unless table_exists?(table) && column_exists?(table, column)

    add_check_constraint table, "#{column} IS NOT NULL",
                         name: name,
                         validate: false
    change_column_null table, column, true
  end
end
