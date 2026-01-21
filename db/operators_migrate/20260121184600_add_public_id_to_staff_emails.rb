# frozen_string_literal: true

class AddPublicIdToStaffEmails < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :staff_emails, :public_id, :string, limit: 21, if_not_exists: true

    reversible do |dir|
      dir.up do
        StaffEmail.find_each do |record|
          record.update_columns(public_id: Nanoid.generate(size: 21))
        end
      end
    end

    safety_assured { change_column_null :staff_emails, :public_id, false }
    add_index :staff_emails, :public_id, unique: true, algorithm: :concurrently, if_not_exists: true
  end
end
