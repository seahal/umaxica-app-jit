# frozen_string_literal: true

class AddUserSecretUpdatedEvent < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      # Add USER_SECRET_UPDATED event
      execute "INSERT INTO user_audit_events (id) VALUES (24)"

      # Update sequence to continue from 24
      execute "SELECT setval(pg_get_serial_sequence('user_audit_events', 'id'), 24)"
    end
  end

  def down
    safety_assured do
      execute "DELETE FROM user_audit_events WHERE id = 24"
    end
  end
end
