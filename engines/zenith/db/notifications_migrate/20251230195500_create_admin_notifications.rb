# typed: false
# frozen_string_literal: true

class CreateAdminNotifications < ActiveRecord::Migration[8.2]
  def change
    create_table(:admin_notifications) do |t|
      t.string(:public_id, null: false, default: "")
      t.bigint(:staff_notification_id, null: false)

      t.timestamps
    end

    add_index(:admin_notifications, :staff_notification_id, if_not_exists: true)
  end
end
