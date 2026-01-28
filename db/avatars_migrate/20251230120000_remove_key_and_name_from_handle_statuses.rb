# frozen_string_literal: true

class RemoveKeyAndNameFromHandleStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_index :handle_statuses, :key, if_exists: true
      remove_column :handle_statuses, :key, :string
      remove_column :handle_statuses, :name, :string
    end
  end
end
