# frozen_string_literal: true

class RemoveDescriptionFromContactCategoriesAndStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :app_contact_categories, :description, :string
      remove_column :com_contact_categories, :description, :string
      remove_column :org_contact_categories, :description, :string

      remove_column :app_contact_statuses, :description, :string
      remove_column :com_contact_statuses, :description, :string
      remove_column :org_contact_statuses, :description, :string
    end
  end
end
