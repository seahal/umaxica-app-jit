# frozen_string_literal: true

class AddStatusIdToAppPreferences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :app_preferences, :status_id, :string, limit: 255, default: "NEYO", null: false
    add_index :app_preferences, :status_id, algorithm: :concurrently
  end
end
