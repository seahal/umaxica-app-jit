# frozen_string_literal: true

class AddDeviceIdToPreferences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    add_column :app_preferences, :device_id, :string unless column_exists?(:app_preferences, :device_id)
    add_column :com_preferences, :device_id, :string unless column_exists?(:com_preferences, :device_id)
    add_column :org_preferences, :device_id, :string unless column_exists?(:org_preferences, :device_id)

    add_index :app_preferences, :device_id, algorithm: :concurrently unless index_exists?(:app_preferences, :device_id)
    add_index :com_preferences, :device_id, algorithm: :concurrently unless index_exists?(:com_preferences, :device_id)
    add_index :org_preferences, :device_id, algorithm: :concurrently unless index_exists?(:org_preferences, :device_id)
  end

  def down
    remove_index :app_preferences, :device_id if index_exists?(:app_preferences, :device_id)
    remove_index :com_preferences, :device_id if index_exists?(:com_preferences, :device_id)
    remove_index :org_preferences, :device_id if index_exists?(:org_preferences, :device_id)

    remove_column :app_preferences, :device_id if column_exists?(:app_preferences, :device_id)
    remove_column :com_preferences, :device_id if column_exists?(:com_preferences, :device_id)
    remove_column :org_preferences, :device_id if column_exists?(:org_preferences, :device_id)
  end
end
