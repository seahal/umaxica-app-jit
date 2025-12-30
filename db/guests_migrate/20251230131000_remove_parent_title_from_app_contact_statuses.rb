# frozen_string_literal: true

class RemoveParentTitleFromAppContactStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :app_contact_statuses, :parent_title, :string if column_exists?(:app_contact_statuses, :parent_title)
    end
  end
end
