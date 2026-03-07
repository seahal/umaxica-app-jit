# frozen_string_literal: true

class CreateMemberNotifications < ActiveRecord::Migration[8.2]
  def change
    create_table :member_notifications do |t|
      t.string :public_id, null: false, default: ""
      t.bigint :user_notification_id, null: false

      t.timestamps
    end

    add_index :member_notifications, :public_id, unique: true, if_not_exists: true
    add_index :member_notifications, :user_notification_id, if_not_exists: true
  end
end
