# frozen_string_literal: true

class RemovePositionFromAppContactCategoriesAndStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :app_contact_categories, :position, :integer if column_exists?(:app_contact_categories, :position)
      remove_column :app_contact_statuses, :position, :integer if column_exists?(:app_contact_statuses, :position)
      remove_column :com_contact_categories, :position, :integer if column_exists?(:com_contact_categories, :position)
      remove_column :com_contact_statuses, :position, :integer if column_exists?(:com_contact_statuses, :position)
      remove_column :org_contact_categories, :position, :integer if column_exists?(:org_contact_categories, :position)
      remove_column :org_contact_statuses, :position, :integer if column_exists?(:org_contact_statuses, :position)
    end
  end
end
