# frozen_string_literal: true

class AddNotNullToGuestContactStatuses < ActiveRecord::Migration[8.2]
  def change
    add_not_null_check(:org_contacts, :contact_status_id, "org_contacts_contact_status_id_null")
    add_not_null_check(:com_contacts, :contact_status_id, "com_contacts_contact_status_id_null")
    add_not_null_check(:app_contacts, :contact_status_id, "app_contacts_contact_status_id_null")
  end

  private

  def add_not_null_check(table, column, name)
    return unless table_exists?(table) && column_exists?(table, column)

    add_check_constraint table, "#{column} IS NOT NULL",
                         name: name,
                         validate: false
  end
end
