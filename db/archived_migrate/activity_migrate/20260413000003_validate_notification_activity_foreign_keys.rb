# frozen_string_literal: true

class ValidateNotificationActivityForeignKeys < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key "notification_activities", "notification_activity_events"
    validate_foreign_key "notification_activities", "notification_activity_levels"
  end
end