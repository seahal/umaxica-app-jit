# frozen_string_literal: true

class RemoveActiveFromContactStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :app_contact_statuses, :active, :boolean
      remove_column :com_contact_statuses, :active, :boolean
      remove_column :org_contact_statuses, :active, :boolean
    end
  end
end
