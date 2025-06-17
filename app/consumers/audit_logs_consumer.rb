# frozen_string_literal: true

# Consumer for handling audit log events
class AuditLogsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      audit_data = JSON.parse(message.payload)

      case audit_data["action"]
      when "create", "update", "delete"
        handle_crud_audit(audit_data)
      when "login", "logout"
        handle_auth_audit(audit_data)
      when "permission_change"
        handle_permission_audit(audit_data)
      when "data_access"
        handle_data_access_audit(audit_data)
      else
        Rails.logger.warn "Unknown audit action: #{audit_data['action']}"
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse audit log message: #{e.message}"
    rescue StandardError => e
      Rails.logger.error "Error processing audit log: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end
  end

  private

  def handle_crud_audit(data)
    user_id = data["user_id"]
    action = data["action"]
    resource_type = data["resource_type"]
    resource_id = data["resource_id"]
    changes = data["changes"]
    timestamp = data["timestamp"]

    Rails.logger.info "AUDIT: User #{user_id} performed #{action} on #{resource_type}:#{resource_id}"

    # Store audit log in database or external system
    # AuditLog.create(
    #   user_id: user_id,
    #   action: action,
    #   resource_type: resource_type,
    #   resource_id: resource_id,
    #   changes: changes,
    #   created_at: timestamp
    # )
  end

  def handle_auth_audit(data)
    user_id = data["user_id"]
    action = data["action"]
    ip_address = data["ip_address"]
    user_agent = data["user_agent"]
    success = data["success"]
    timestamp = data["timestamp"]

    Rails.logger.info "AUDIT: User #{user_id} #{action} from #{ip_address}, success: #{success}"

    # Store authentication audit
    # AuthAuditLog.create(
    #   user_id: user_id,
    #   action: action,
    #   ip_address: ip_address,
    #   user_agent: user_agent,
    #   success: success,
    #   created_at: timestamp
    # )
  end

  def handle_permission_audit(data)
    admin_user_id = data["admin_user_id"]
    target_user_id = data["target_user_id"]
    permission = data["permission"]
    granted = data["granted"]
    timestamp = data["timestamp"]

    Rails.logger.info "AUDIT: Admin #{admin_user_id} #{granted ? 'granted' : 'revoked'} permission '#{permission}' for user #{target_user_id}"

    # Store permission change audit
    # PermissionAuditLog.create(
    #   admin_user_id: admin_user_id,
    #   target_user_id: target_user_id,
    #   permission: permission,
    #   granted: granted,
    #   created_at: timestamp
    # )
  end

  def handle_data_access_audit(data)
    user_id = data["user_id"]
    resource_type = data["resource_type"]
    resource_id = data["resource_id"]
    access_type = data["access_type"] # 'read', 'export', 'download'
    timestamp = data["timestamp"]

    Rails.logger.info "AUDIT: User #{user_id} accessed #{resource_type}:#{resource_id} via #{access_type}"

    # Store data access audit
    # DataAccessAuditLog.create(
    #   user_id: user_id,
    #   resource_type: resource_type,
    #   resource_id: resource_id,
    #   access_type: access_type,
    #   created_at: timestamp
    # )
  end
end
