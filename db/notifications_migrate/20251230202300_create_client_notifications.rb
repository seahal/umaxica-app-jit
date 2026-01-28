# frozen_string_literal: true

class CreateClientNotifications < ActiveRecord::Migration[8.2]
  NIL_UUID = "00000000-0000-0000-0000-000000000000"

  def change
    create_table :client_notifications, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :public_id, default: NIL_UUID, null: false
      t.uuid :user_notification_id, default: NIL_UUID, null: false

      t.timestamps
    end

    add_index :client_notifications, :user_notification_id, if_not_exists: true
  end
end
