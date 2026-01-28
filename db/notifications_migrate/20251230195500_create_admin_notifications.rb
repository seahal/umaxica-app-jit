# frozen_string_literal: true

class CreateAdminNotifications < ActiveRecord::Migration[8.2]
  NIL_UUID = "00000000-0000-0000-0000-000000000000"

  def change
    create_table :admin_notifications, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :public_id, default: NIL_UUID, null: false
      t.uuid :staff_notification_id, default: NIL_UUID, null: false

      t.timestamps
    end

    add_index :admin_notifications, :staff_notification_id, if_not_exists: true
  end
end
