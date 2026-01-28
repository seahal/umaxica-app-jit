# frozen_string_literal: true

class AddWithdrawalTrackingToUsers < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :users, :withdraw_requested_at, :datetime
    add_column :users, :withdraw_scheduled_at, :datetime
    add_column :users, :withdraw_cooldown_until, :datetime

    add_index :users, :withdraw_scheduled_at, algorithm: :concurrently
    add_index :users, :withdraw_cooldown_until, algorithm: :concurrently
  end
end
