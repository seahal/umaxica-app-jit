# frozen_string_literal: true

class FixNotificationConsistency < ActiveRecord::Migration[8.2]
  def change
    add_index :user_notifications, :user_id, if_not_exists: true
    add_index :staff_notifications, :staff_id, if_not_exists: true
  end
end
