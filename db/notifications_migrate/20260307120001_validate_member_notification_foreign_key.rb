# frozen_string_literal: true

class ValidateMemberNotificationForeignKey < ActiveRecord::Migration[8.2]
  def change
    return unless foreign_key_exists?(:member_notifications, :user_notifications, column: :user_notification_id)

    validate_foreign_key(:member_notifications, :user_notifications)
  end
end
