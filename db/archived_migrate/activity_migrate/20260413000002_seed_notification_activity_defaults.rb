# frozen_string_literal: true

class SeedNotificationActivityDefaults < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      NotificationActivityEvent.ensure_defaults!
      NotificationActivityLevel.ensure_defaults!
    end
  end

  def down
    # Seed data is idempotent; no rollback needed.
  end
end
