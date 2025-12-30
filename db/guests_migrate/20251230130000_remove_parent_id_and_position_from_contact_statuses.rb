# frozen_string_literal: true

class RemoveParentIdAndPositionFromContactStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      %i(com_contact_statuses org_contact_statuses).each do |table|
        remove_index table, :parent_id, if_exists: true
        remove_column table, :parent_id, :string if column_exists?(table, :parent_id)
        remove_column table, :position, :integer if column_exists?(table, :position)
      end
    end
  end
end
