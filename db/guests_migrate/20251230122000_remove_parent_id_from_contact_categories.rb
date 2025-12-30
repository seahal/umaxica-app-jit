# frozen_string_literal: true

class RemoveParentIdFromContactCategories < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      %i(app_contact_categories com_contact_categories org_contact_categories).each do |table|
        remove_index table, :parent_id, if_exists: true
        remove_column table, :parent_id, :string if column_exists?(table, :parent_id)
      end
    end
  end
end
