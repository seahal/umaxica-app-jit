# typed: false
# frozen_string_literal: true

# Fix type mismatch: avatar_assignments.user_id was uuid but User.id is now bigint.
# This migration converts the user_id column to bigint to match the User table's primary key.
class ConvertAvatarAssignmentUserIdToBigint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # Remove existing data as types are incompatible (uuid strings cannot be cast to bigint)
      execute("TRUNCATE TABLE avatar_assignments RESTART IDENTITY CASCADE")

      # Drop the old uuid column and add new bigint column
      remove_column(:avatar_assignments, :user_id)
      add_column(:avatar_assignments, :user_id, :bigint, null: false, default: 0)
      change_column_default(:avatar_assignments, :user_id, from: 0, to: nil)

      # Re-add the index
      add_index(:avatar_assignments, :user_id, name: "index_avatar_assignments_on_user_id")
    end
  end

  def down
    safety_assured do
      execute("TRUNCATE TABLE avatar_assignments RESTART IDENTITY CASCADE")
      remove_column(:avatar_assignments, :user_id)
      add_column(
        :avatar_assignments, :user_id, :bigint, null: false,
                                                default: "00000000-0000-0000-0000-000000000000",
      )
      change_column_default(
        :avatar_assignments, :user_id,
        from: "00000000-0000-0000-0000-000000000000", to: nil,
      )
      add_index(:avatar_assignments, :user_id, name: "index_avatar_assignments_on_user_id")
    end
  end
end
