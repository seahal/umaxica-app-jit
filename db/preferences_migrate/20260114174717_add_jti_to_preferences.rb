# frozen_string_literal: true

class AddJtiToPreferences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :app_preferences, :jti, :string
    add_column :org_preferences, :jti, :string
    add_column :com_preferences, :jti, :string

    add_index :app_preferences, :jti, unique: true, algorithm: :concurrently
    add_index :org_preferences, :jti, unique: true, algorithm: :concurrently
    add_index :com_preferences, :jti, unique: true, algorithm: :concurrently
  end
end
