# frozen_string_literal: true

class AddPublicIdAndUserStatusIdToUsers < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      change_table(:users, bulk: true) do |t|
        t.string(:public_id, limit: 255)
        t.string(:user_status_id, limit: 255, null: false, default: "NONE")
      end
    end
    add_index(:users, :public_id, unique: true, algorithm: :concurrently)
    add_index(:users, :user_status_id, algorithm: :concurrently)
    add_foreign_key(:users, :user_identity_statuses, column: :user_status_id, primary_key: :id, validate: false)
  end

  def down
    remove_foreign_key(:users, :user_identity_statuses)
    remove_index(:users, :user_status_id, algorithm: :concurrently)
    remove_index(:users, :public_id, algorithm: :concurrently)
    change_table(:users, bulk: true) do |t|
      t.remove(:user_status_id)
      t.remove(:public_id)
    end
  end
end
