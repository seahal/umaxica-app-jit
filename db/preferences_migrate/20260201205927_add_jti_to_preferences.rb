# frozen_string_literal: true

class AddJtiToPreferences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    add_column :app_preferences, :jti, :string unless column_exists?(:app_preferences, :jti)
    add_column :com_preferences, :jti, :string unless column_exists?(:com_preferences, :jti)
    add_column :org_preferences, :jti, :string unless column_exists?(:org_preferences, :jti)

    add_index :app_preferences, :jti, unique: true, algorithm: :concurrently unless index_exists?(:app_preferences, :jti)
    add_index :com_preferences, :jti, unique: true, algorithm: :concurrently unless index_exists?(:com_preferences, :jti)
    add_index :org_preferences, :jti, unique: true, algorithm: :concurrently unless index_exists?(:org_preferences, :jti)
  end

  def down
    remove_index :app_preferences, :jti if index_exists?(:app_preferences, :jti)
    remove_index :com_preferences, :jti if index_exists?(:com_preferences, :jti)
    remove_index :org_preferences, :jti if index_exists?(:org_preferences, :jti)

    remove_column :app_preferences, :jti if column_exists?(:app_preferences, :jti)
    remove_column :com_preferences, :jti if column_exists?(:com_preferences, :jti)
    remove_column :org_preferences, :jti if column_exists?(:org_preferences, :jti)
  end
end
