# frozen_string_literal: true

class AddUniqueIndexToAvatarAssignments < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      return unless table_exists?(:avatar_assignments)

      add_index :avatar_assignments,
                %i(avatar_id user_id role),
                unique: true,
                name: "index_avatar_assignments_unique",
                algorithm: :concurrently,
                if_not_exists: true
    end
  end

  def down
    safety_assured do
      remove_index :avatar_assignments,
                   name: "index_avatar_assignments_unique",
                   algorithm: :concurrently,
                   if_exists: true
    end
  end
end
