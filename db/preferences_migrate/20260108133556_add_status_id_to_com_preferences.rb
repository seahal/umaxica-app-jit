# frozen_string_literal: true

class AddStatusIdToComPreferences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :com_preferences, :status_id, :string, limit: 255, default: "NEYO", null: false
    add_index :com_preferences, :status_id, algorithm: :concurrently
  end
end
