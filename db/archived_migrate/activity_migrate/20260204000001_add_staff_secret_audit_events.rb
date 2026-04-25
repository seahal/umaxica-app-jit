# frozen_string_literal: true

class AddStaffSecretAuditEvents < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      # Add STAFF_SECRET_CREATED, STAFF_SECRET_REMOVED, and STAFF_SECRET_UPDATED events
      execute("INSERT INTO staff_audit_events (id) VALUES (8)")
      execute("INSERT INTO staff_audit_events (id) VALUES (9)")
      execute("INSERT INTO staff_audit_events (id) VALUES (10)")

      # Update sequence to continue from 10
      execute("SELECT setval(pg_get_serial_sequence('staff_audit_events', 'id'), 10)")
    end
  end

  def down
    safety_assured do
      execute("DELETE FROM staff_audit_events WHERE id IN (8, 9, 10)")
    end
  end
end
