# frozen_string_literal: true

class DefaultContactStatusToNone < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      execute("UPDATE app_contacts SET contact_status_id = 'NONE' WHERE contact_status_id IS NULL")
      execute("UPDATE com_contacts SET contact_status_id = 'NONE' WHERE contact_status_id IS NULL")
      execute("UPDATE org_contacts SET contact_status_id = 'NONE' WHERE contact_status_id IS NULL")

      change_column_default(:app_contacts, :contact_status_id, from: nil, to: "NONE")
      change_column_default(:com_contacts, :contact_status_id, from: nil, to: "NONE")
      change_column_default(:org_contacts, :contact_status_id, from: nil, to: "NONE")
    end
  end

  def down
    safety_assured do
      change_column_default(:org_contacts, :contact_status_id, from: "NONE", to: nil)
      change_column_default(:com_contacts, :contact_status_id, from: "NONE", to: nil)
      change_column_default(:app_contacts, :contact_status_id, from: "NONE", to: nil)
    end
  end
end
