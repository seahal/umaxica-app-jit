# typed: false
# frozen_string_literal: true

class RenameAdminNotificationToOperatorNotification < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      rename_table(:admin_notifications, :operator_notifications)
      rename_public_id_index
      rename_staff_notification_id_index
    end
  end

  private

  def rename_public_id_index
    old_name = :index_admin_notifications_on_public_id
    new_name = :index_operator_notifications_on_public_id

    return unless index_exists?(:operator_notifications, :public_id, name: old_name)

    rename_index(:operator_notifications, old_name, new_name)
  end

  def rename_staff_notification_id_index
    old_name = :index_admin_notifications_on_staff_notification_id
    new_name = :index_operator_notifications_on_staff_notification_id

    return unless index_exists?(:operator_notifications, :staff_notification_id, name: old_name)

    rename_index(:operator_notifications, old_name, new_name)
  end
end
