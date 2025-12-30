# frozen_string_literal: true

class AddStatusIdToAdmins < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      change_table :admins, bulk: true do |t|
        t.string :status_id, limit: 255, default: "NEYO", null: false
      end

      add_index :admins, :status_id
      add_foreign_key :admins, :admin_identity_statuses, column: :status_id, primary_key: :id
    end
  end

  def down
    remove_foreign_key :admins, :admin_identity_statuses
    remove_index :admins, :status_id
    change_table :admins, bulk: true do |t|
      t.remove :status_id
    end
  end
end
