# frozen_string_literal: true

class AddPublicIdToStaffSecrets < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column(:staff_secrets, :public_id, :string, limit: 21, if_not_exists: true)

    reversible do |dir|
      dir.up do
        safety_assured do
        end
      end
    end

    safety_assured { change_column_null(:staff_secrets, :public_id, false) }
    add_index(:staff_secrets, :public_id, unique: true, algorithm: :concurrently, if_not_exists: true)
  end
end
