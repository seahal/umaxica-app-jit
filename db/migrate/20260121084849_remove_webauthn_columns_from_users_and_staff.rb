# frozen_string_literal: true

class RemoveWebauthnColumnsFromUsersAndStaff < ActiveRecord::Migration[8.2]
  def change
    remove_column :users, :webauthn_id, :string if column_exists?(:users, :webauthn_id)
    remove_column :staffs, :webauthn_id, :string if column_exists?(:staffs, :webauthn_id)
  end
end
