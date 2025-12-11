class CreateRoleAssignments < ActiveRecord::Migration[8.2]
  def change
    create_table :role_assignments, id: :uuid do |t|
      t.uuid :user_id
      t.uuid :staff_id
      t.uuid :role_id, null: false

      t.timestamps
    end

    add_index :role_assignments, [ :user_id, :role_id ],
              unique: true, name: "index_role_assignments_on_user_role"
    add_index :role_assignments, [ :staff_id, :role_id ],
              unique: true, name: "index_role_assignments_on_staff_role"
    add_index :role_assignments, :role_id

    add_foreign_key :role_assignments, :roles
  end
end
