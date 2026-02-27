# frozen_string_literal: true

class ValidateMissingNotificationForeignKeys < ActiveRecord::Migration[8.2]
  def change
    validate_notification_fk(
      :client_notifications, :user_notifications,
      column: :user_notification_id,
    )
    validate_notification_fk(
      :admin_notifications, :staff_notifications,
      column: :staff_notification_id,
    )
  end

  private

  def validate_notification_fk(from_table, to_table, column:)
    return unless foreign_key_exists?(from_table, to_table, column: column)

    validate_foreign_key from_table, to_table
  end
end
