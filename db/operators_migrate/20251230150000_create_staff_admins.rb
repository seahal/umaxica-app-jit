# frozen_string_literal: true

class CreateStaffAdmins < ActiveRecord::Migration[8.2]
  def change
    create_table :staff_admins, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :staff_id, null: false
      t.uuid :admin_id, null: false

      t.timestamps
    end

    add_index :staff_admins, [:staff_id, :admin_id], unique: true
    add_index :staff_admins, :staff_id
    add_index :staff_admins, :admin_id

    add_foreign_key :staff_admins, :staffs, on_delete: :cascade, validate: false
    add_foreign_key :staff_admins, :admins, on_delete: :cascade, validate: false
  end
end
