# typed: false
# frozen_string_literal: true

class CreateClientNotifications < ActiveRecord::Migration[8.2]
  def change
    create_table(:client_notifications) do |t|
      t.string(:public_id, null: false, default: "")
      t.bigint(:user_notification_id, null: false)

      t.timestamps
    end

    add_index(:client_notifications, :user_notification_id, if_not_exists: true)
  end
end
