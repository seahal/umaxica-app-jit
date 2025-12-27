# frozen_string_literal: true

class RemoveRedundantIndexes < ActiveRecord::Migration[8.2]
  def change
    remove_index :user_memberships, column: :user_id, name: :index_user_memberships_on_user_id
    remove_index :role_assignments, column: :staff_id, name: :index_role_assignments_on_staff_id
    remove_index :role_assignments, column: :user_id, name: :index_role_assignments_on_user_id
  end
end
