# frozen_string_literal: true

class RemoveActiveFromContactCategories < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :app_contact_categories, :active, :boolean
      remove_column :com_contact_categories, :active, :boolean
      remove_column :org_contact_categories, :active, :boolean
    end
  end
end
