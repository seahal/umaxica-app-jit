class AddLoginAuditEventsForStaff < ActiveRecord::Migration[8.2]
  def up
    # Add login-related audit events for staff
    StaffIdentityAuditEvent.create!(id: "LOGGED_IN") unless StaffIdentityAuditEvent.exists?(id: "LOGGED_IN")
    StaffIdentityAuditEvent.create!(id: "LOGGED_OUT") unless StaffIdentityAuditEvent.exists?(id: "LOGGED_OUT")
    StaffIdentityAuditEvent.create!(id: "LOGIN_FAILED") unless StaffIdentityAuditEvent.exists?(id: "LOGIN_FAILED")
    StaffIdentityAuditEvent.create!(id: "TOKEN_REFRESHED") unless StaffIdentityAuditEvent.exists?(id: "TOKEN_REFRESHED")
  end

  def down
    # Remove login-related audit events for staff
    StaffIdentityAuditEvent.where(id: %w[LOGGED_IN LOGGED_OUT LOGIN_FAILED TOKEN_REFRESHED]).destroy_all
  end
end
