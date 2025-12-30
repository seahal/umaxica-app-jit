# frozen_string_literal: true

class RenameIdentityStatusColumnsToStatusId < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      if foreign_key_exists?(:users, :user_identity_statuses, column: :user_identity_status_id)
        remove_foreign_key :users, :user_identity_statuses, column: :user_identity_status_id
      end
      if foreign_key_exists?(:staffs, :staff_identity_statuses, column: :staff_identity_status_id)
        remove_foreign_key :staffs, :staff_identity_statuses, column: :staff_identity_status_id
      end

      rename_column :users, :user_identity_status_id, :status_id if column_exists?(:users, :user_identity_status_id)
      rename_column :staffs, :staff_identity_status_id, :status_id if column_exists?(:staffs, :staff_identity_status_id)

      if index_exists?(:users, :user_identity_status_id, name: "index_users_on_user_identity_status_id")
        rename_index :users, "index_users_on_user_identity_status_id", "index_users_on_status_id"
      end
      if index_exists?(:staffs, :staff_identity_status_id, name: "index_staffs_on_staff_identity_status_id")
        rename_index :staffs, "index_staffs_on_staff_identity_status_id", "index_staffs_on_status_id"
      end

      unless foreign_key_exists?(:users, :user_identity_statuses, column: :status_id)
        add_foreign_key :users, :user_identity_statuses, column: :status_id, primary_key: :id
      end
      unless foreign_key_exists?(:staffs, :staff_identity_statuses, column: :status_id)
        add_foreign_key :staffs, :staff_identity_statuses, column: :status_id, primary_key: :id
      end
    end
  end
end
