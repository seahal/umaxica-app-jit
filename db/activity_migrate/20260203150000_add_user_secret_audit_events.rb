# frozen_string_literal: true

class AddUserSecretAuditEvents < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      # Add USER_SECRET_CREATED and USER_SECRET_REMOVED events
      execute("INSERT INTO user_audit_events (id) VALUES (22)")
      execute("INSERT INTO user_audit_events (id) VALUES (23)")

      # Update sequence to continue from 23
      execute("SELECT setval(pg_get_serial_sequence('user_audit_events', 'id'), 23)")
    end
  end

  def down
    safety_assured do
      execute("DELETE FROM user_audit_events WHERE id IN (22, 23)")
    end
  end
end
