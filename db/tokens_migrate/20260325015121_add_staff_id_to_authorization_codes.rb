# frozen_string_literal: true

class AddStaffIdToAuthorizationCodes < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    change_column_null :authorization_codes, :user_id, true

    add_column :authorization_codes, :staff_id, :bigint, null: true
    add_index  :authorization_codes, :staff_id, algorithm: :concurrently

    reversible do |dir|
      dir.up do
        safety_assured do
          execute <<~SQL
            ALTER TABLE authorization_codes
              ADD CONSTRAINT chk_authorization_codes_resource
              CHECK (
                (user_id IS NOT NULL AND staff_id IS NULL)
                OR
                (user_id IS NULL AND staff_id IS NOT NULL)
              );
          SQL
        end
      end

      dir.down do
        execute <<~SQL
          ALTER TABLE authorization_codes
            DROP CONSTRAINT IF EXISTS chk_authorization_codes_resource;
        SQL
      end
    end
  end
end
