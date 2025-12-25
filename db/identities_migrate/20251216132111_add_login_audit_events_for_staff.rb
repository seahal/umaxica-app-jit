class AddLoginAuditEventsForStaff < ActiveRecord::Migration[8.2]
  def up
    # Add login-related audit events for staff
    execute("INSERT INTO staff_identity_audit_events (id) VALUES ('LOGGED_IN') ON CONFLICT (id) DO NOTHING")
    execute("INSERT INTO staff_identity_audit_events (id) VALUES ('LOGGED_OUT') ON CONFLICT (id) DO NOTHING")
    execute("INSERT INTO staff_identity_audit_events (id) VALUES ('LOGIN_FAILED') ON CONFLICT (id) DO NOTHING")
    execute("INSERT INTO staff_identity_audit_events (id) VALUES ('TOKEN_REFRESHED') ON CONFLICT (id) DO NOTHING")
  end

  def down
    # Remove login-related audit events for staff
    execute("DELETE FROM staff_identity_audit_events WHERE id IN ('LOGGED_IN', 'LOGGED_OUT', 'LOGIN_FAILED', 'TOKEN_REFRESHED')")
  end
end
