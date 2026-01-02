# frozen_string_literal: true

class FixDatabaseConsistencyNotification < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    # Add foreign keys for notification associations
    unless foreign_key_exists?(
      :client_notifications, :user_notifications,
      column: :user_notification_id,
    )
      add_foreign_key :client_notifications, :user_notifications,
                      column: :user_notification_id,
                      validate: false
      validate_foreign_key :client_notifications, :user_notifications
    end

    unless foreign_key_exists?(
      :admin_notifications, :staff_notifications,
      column: :staff_notification_id,
    )
      add_foreign_key :admin_notifications, :staff_notifications,
                      column: :staff_notification_id,
                      validate: false
      validate_foreign_key :admin_notifications, :staff_notifications
    end
  end

  def down
    remove_foreign_key :admin_notifications, :staff_notifications
    remove_foreign_key :client_notifications, :user_notifications
  end
end
