# frozen_string_literal: true

class RemoveKeyAndNameFromIdentityStatusMasters < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_index :avatar_membership_statuses, :key, if_exists: true
      remove_index :avatar_moniker_statuses, :key, if_exists: true
      remove_index :avatar_ownership_statuses, :key, if_exists: true
      remove_index :handle_assignment_statuses, :key, if_exists: true
      remove_index :post_statuses, :key, if_exists: true

      remove_column :avatar_membership_statuses, :key, :string
      remove_column :avatar_membership_statuses, :name, :string
      remove_column :avatar_moniker_statuses, :key, :string
      remove_column :avatar_moniker_statuses, :name, :string
      remove_column :avatar_ownership_statuses, :key, :string
      remove_column :avatar_ownership_statuses, :name, :string
      remove_column :handle_assignment_statuses, :key, :string
      remove_column :handle_assignment_statuses, :name, :string
      remove_column :post_statuses, :key, :string
      remove_column :post_statuses, :name, :string
    end
  end
end
