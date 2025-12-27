# frozen_string_literal: true

class CreateAvatarAssignments < ActiveRecord::Migration[8.2]
  def change
    create_table :avatar_assignments, id: :uuid do |t|
      t.string :avatar_id, null: false, limit: 255
      t.uuid :user_id, null: false
      t.string :role, null: false, default: "viewer", limit: 50

      t.timestamps
    end

    # Foreign keys with cascade delete
    add_foreign_key :avatar_assignments, :avatars,
                    column: :avatar_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :avatar_assignments, :users,
                    column: :user_id, primary_key: :id, on_delete: :cascade

    # Composite unique index for avatar_id + user_id + role
    add_index :avatar_assignments, %i(avatar_id user_id role),
              unique: true, name: "index_avatar_assignments_unique"

    # Conditional unique indexes for owner and affiliation (only one per avatar)
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          CREATE UNIQUE INDEX index_avatar_assignments_unique_owner
          ON avatar_assignments (avatar_id)
          WHERE role = 'owner';
        SQL

        execute <<-SQL.squish
          CREATE UNIQUE INDEX index_avatar_assignments_unique_affiliation
          ON avatar_assignments (avatar_id)
          WHERE role = 'affiliation';
        SQL

        # CHECK constraint for valid roles
        execute <<-SQL.squish
          ALTER TABLE avatar_assignments
          ADD CONSTRAINT check_avatar_assignment_role
          CHECK (role IN ('owner', 'affiliation', 'administrator', 'editor', 'reviewer', 'viewer'));
        SQL
      end

      dir.down do
        execute "ALTER TABLE avatar_assignments DROP CONSTRAINT IF EXISTS check_avatar_assignment_role"
        execute "DROP INDEX IF EXISTS index_avatar_assignments_unique_affiliation"
        execute "DROP INDEX IF EXISTS index_avatar_assignments_unique_owner"
      end
    end
  end
end
