class AddLoginAuditEvents < ActiveRecord::Migration[8.0]
  def up
    # Add login-related audit events
    UserIdentityAuditEvent.create!(id: "LOGGED_IN") unless UserIdentityAuditEvent.exists?(id: "LOGGED_IN")
    UserIdentityAuditEvent.create!(id: "LOGGED_OUT") unless UserIdentityAuditEvent.exists?(id: "LOGGED_OUT")
    UserIdentityAuditEvent.create!(id: "LOGIN_FAILED") unless UserIdentityAuditEvent.exists?(id: "LOGIN_FAILED")
    UserIdentityAuditEvent.create!(id: "TOKEN_REFRESHED") unless UserIdentityAuditEvent.exists?(id: "TOKEN_REFRESHED")
  end

  def down
    # Remove login-related audit events
    UserIdentityAuditEvent.where(id: %w[LOGGED_IN LOGGED_OUT LOGIN_FAILED TOKEN_REFRESHED]).destroy_all
  end
end
