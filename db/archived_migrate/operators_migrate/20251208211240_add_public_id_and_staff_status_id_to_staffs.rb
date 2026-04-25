# frozen_string_literal: true

class AddPublicIdAndStaffStatusIdToStaffs < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      change_table(:staffs, bulk: true) do |t|
        t.string(:public_id, limit: 255)
        t.string(:staff_status_id, limit: 255, default: "NONE", null: false)
      end
    end

    add_index(:staffs, :public_id, unique: true, algorithm: :concurrently)
    add_index(:staffs, :staff_status_id, algorithm: :concurrently)
    add_foreign_key(:staffs, :staff_identity_statuses, column: :staff_status_id, primary_key: :id, validate: false)
  end

  def down
    remove_foreign_key(:staffs, :staff_identity_statuses)
    remove_index(:staffs, :staff_status_id, algorithm: :concurrently)
    remove_index(:staffs, :public_id, algorithm: :concurrently)
    change_table(:staffs, bulk: true) do |t|
      t.remove(:staff_status_id)
      t.remove(:public_id)
    end
  end
end
