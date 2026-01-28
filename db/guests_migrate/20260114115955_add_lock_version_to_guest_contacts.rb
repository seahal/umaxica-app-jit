# frozen_string_literal: true

class AddLockVersionToGuestContacts < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      %i[app_contacts com_contacts org_contacts].each do |table_name|
        add_column table_name, :lock_version, :integer, null: false, default: 0
      end
    end
  end
end
