# frozen_string_literal: true

class AddWithdrawalFieldsToUsers < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    change_column_default :users, :status_id, from: "NEYO", to: "ACTIVE"

    add_column :users, :withdraw_requested_at, :datetime, if_not_exists: true
    add_column :users, :withdraw_scheduled_at, :datetime, if_not_exists: true
    add_column :users, :withdraw_cooldown_until, :datetime, if_not_exists: true

    add_index :users, :withdraw_scheduled_at, if_not_exists: true, algorithm: :concurrently
    add_index :users, :withdraw_cooldown_until, if_not_exists: true, algorithm: :concurrently
  end
end
