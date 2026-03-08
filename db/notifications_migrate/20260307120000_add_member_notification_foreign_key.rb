# frozen_string_literal: true

class AddMemberNotificationForeignKey < ActiveRecord::Migration[8.2]
  def change
    return unless table_exists?(:member_notifications) && table_exists?(:user_notifications)
    return if foreign_key_exists?(:member_notifications, :user_notifications, column: :user_notification_id)

    add_foreign_key :member_notifications, :user_notifications,
                    column: :user_notification_id, validate: false
  end
end
