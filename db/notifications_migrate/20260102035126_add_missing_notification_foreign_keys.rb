# frozen_string_literal: true

class AddMissingNotificationForeignKeys < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :client_notifications, :user_notifications,
                    column: :user_notification_id, validate: false

    add_foreign_key :admin_notifications, :staff_notifications,
                    column: :staff_notification_id, validate: false
  end
end
