# frozen_string_literal: true

class AddDefaultsToGuestContactFks < ActiveRecord::Migration[8.2]
  def up
    # Add default values to foreign key columns that were created without defaults
    tables_and_columns = [
      [:org_contacts, :category_id],
      [:org_contact_telephones, :org_contact_id],
      [:org_contact_emails, :org_contact_id],
      [:com_contacts, :category_id],
      [:com_contact_telephones, :com_contact_id],
      [:com_contact_emails, :com_contact_id],
      [:app_contacts, :category_id],
      [:app_contact_telephones, :app_contact_id],
      [:app_contact_emails, :app_contact_id],
    ]

    tables_and_columns.each do |table, column|
      if table_exists?(table) && column_exists?(table, column)
        change_column_default(table, column, 0)
      end
    end
  end

  def down
    tables_and_columns = [
      [:org_contacts, :category_id],
      [:org_contact_telephones, :org_contact_id],
      [:org_contact_emails, :org_contact_id],
      [:com_contacts, :category_id],
      [:com_contact_telephones, :com_contact_id],
      [:com_contact_emails, :com_contact_id],
      [:app_contacts, :category_id],
      [:app_contact_telephones, :app_contact_id],
      [:app_contact_emails, :app_contact_id],
    ]

    tables_and_columns.each do |table, column|
      if table_exists?(table) && column_exists?(table, column)
        change_column_default(table, column, nil)
      end
    end
  end
end
