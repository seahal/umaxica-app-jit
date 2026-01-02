# frozen_string_literal: true

class AddNotNullToForeignKeys < ActiveRecord::Migration[8.2]
  def change
    # Add NOT NULL constraint to contact status foreign keys
    change_column_null :org_contacts, :org_contact_status_id, false
    change_column_null :com_contacts, :com_contact_status_id, false
    change_column_null :app_contacts, :app_contact_status_id, false

    # Add NOT NULL constraint to user_messages.user_id
    change_column_null :user_messages, :user_id, false

    # Add NOT NULL constraint to admins.staff_id
    change_column_null :admins, :staff_id, false
  end
end
