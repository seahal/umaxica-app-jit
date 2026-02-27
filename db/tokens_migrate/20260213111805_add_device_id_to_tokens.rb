# frozen_string_literal: true

class AddDeviceIdToTokens < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :user_tokens, :device_id, :string, null: false, default: "" unless column_exists?(:user_tokens, :device_id)
    add_column :staff_tokens, :device_id, :string, null: false, default: "" unless column_exists?(:staff_tokens, :device_id)
    add_index :user_tokens, :device_id, algorithm: :concurrently unless index_exists?(:user_tokens, :device_id)
    add_index :staff_tokens, :device_id, algorithm: :concurrently unless index_exists?(:staff_tokens, :device_id)
  end
end
