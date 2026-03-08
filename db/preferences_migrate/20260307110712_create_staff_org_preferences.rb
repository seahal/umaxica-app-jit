# frozen_string_literal: true

class CreateStaffOrgPreferences < ActiveRecord::Migration[8.2]
  def change
    create_table :staff_org_preferences, id: :bigserial do |t|
      t.bigint :staff_id, null: false
      t.references :org_preference,
                   null: false,
                   foreign_key: { on_delete: :cascade },
                   type: :bigserial

      t.timestamps
    end

    add_index :staff_org_preferences, :staff_id
    add_index :staff_org_preferences, %i(staff_id org_preference_id), unique: true
  end
end
