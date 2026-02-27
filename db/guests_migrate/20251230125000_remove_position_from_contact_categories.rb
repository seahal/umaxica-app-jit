# frozen_string_literal: true

class RemovePositionFromContactCategories < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      %i(com_contact_categories org_contact_categories).each do |table|
        remove_column table, :position, :integer if column_exists?(table, :position)
      end
    end
  end
end
