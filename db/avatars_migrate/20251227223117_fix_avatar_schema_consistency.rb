# frozen_string_literal: true

class FixAvatarSchemaConsistency < ActiveRecord::Migration[8.2]
  def change
    # Avatar Assignment - Index
    return unless table_exists?(:avatar_assignments)

    remove_index(:avatar_assignments, column: :user_id, if_exists: true)
    add_index(:avatar_assignments, :user_id, if_not_exists: true)

  end
end
