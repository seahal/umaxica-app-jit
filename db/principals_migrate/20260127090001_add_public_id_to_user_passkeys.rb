# frozen_string_literal: true

class AddPublicIdToUserPasskeys < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :user_passkeys, :public_id, :string, limit: 255, default: "", null: false
    add_index :user_passkeys, :public_id, unique: true, algorithm: :concurrently
  end
end
