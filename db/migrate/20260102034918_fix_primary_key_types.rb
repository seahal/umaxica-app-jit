# frozen_string_literal: true

class FixPrimaryKeyTypes < ActiveRecord::Migration[8.2]
  def up
    # Change primary key types from int to bigint
    change_column :staff_identity_passkey_statuses, :id, :bigint
    change_column :division_statuses, :id, :bigint
    change_column :department_statuses, :id, :bigint
    change_column :client_identity_statuses, :id, :bigint
    change_column :admin_identity_statuses, :id, :bigint
  end

  def down
    # Revert to int if needed (though generally not recommended)
    change_column :staff_identity_passkey_statuses, :id, :int
    change_column :division_statuses, :id, :int
    change_column :department_statuses, :id, :int
    change_column :client_identity_statuses, :id, :int
    change_column :admin_identity_statuses, :id, :int
  end
end
