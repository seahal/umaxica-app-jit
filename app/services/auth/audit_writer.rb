# frozen_string_literal: true

module Auth
  # Writes audit records with best-effort semantics
  # Ensures authentication success is not blocked by audit failures
  #
  # Usage:
  #   # Raises exception on failure (use in critical paths)
  #   Auth::AuditWriter.write!(audit_class, event_id, resource:, actor:, ip_address:)
  #
  #   # Returns false on failure, notifies observers (use in auth flows)
  #   Auth::AuditWriter.write(audit_class, event_id, resource:, actor:, ip_address:)
  class AuditWriter
    class AuditWriteError < StandardError; end

    # Writes audit record and raises exception on failure
    # Use this when audit failure should stop the operation
    def self.write!(audit_class, event_id, resource:, actor: nil, ip_address: nil)
      actor ||= resource

      ActivityRecord.connected_to(role: :writing) do
        normalized_event_id = normalize_event_id(audit_class, event_id)
        audit = build_audit(audit_class, normalized_event_id, resource: resource, actor: actor, ip_address: ip_address)

        unless audit.save
          error_message = "Audit save failed: #{audit.errors.full_messages.join(", ")}"
          Rails.logger.error "[Auth::AuditWriter] #{error_message}"
          raise AuditWriteError, error_message
        end

        audit
      end
    end

    # Writes audit record with best-effort semantics
    # Returns true on success, false on failure
    # Notifies observers on failure (via Rails.event.notify)
    # Use this in authentication flows to prevent audit failures from blocking auth
    def self.write(audit_class, event_id, resource:, actor: nil, ip_address: nil)
      write!(audit_class, event_id, resource: resource, actor: actor, ip_address: ip_address)
      true
    rescue StandardError => e
      # Observe the failure without blocking authentication
      Rails.logger.error "[Auth::AuditWriter] Audit write failed (best-effort): #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n") if e.backtrace

      Rails.event.notify(
        "authentication.audit.failed",
        event_id: event_id,
        resource_type: resource.class.name,
        resource_id: resource.id,
        error_class: e.class.name,
        error_message: e.message,
      )

      false
    end

    # Builds audit record without saving
    def self.build_audit(audit_class, event_id, resource:, actor:, ip_address:)
      audit = audit_class.new(
        actor: actor,
        event_id: event_id,
        ip_address: ip_address,
        occurred_at: Time.current,
      )

      if actor
        audit.actor_id = actor.id
        audit.actor_type = actor.class.name
      end

      # Set resource using the appropriate setter method
      # For UserActivity: user= or subject_id=/subject_type=
      # For StaffActivity: staff= or subject_id=/subject_type=
      resource_type = infer_resource_type(audit_class, resource)
      if audit.respond_to?("#{resource_type}=")
        audit.public_send("#{resource_type}=", resource)
      else
        # Fallback to subject_id/subject_type
        audit.subject_id = resource.id.to_s
        audit.subject_type = resource.class.name
      end

      audit
    end

    # Infers resource type from audit class name
    # UserActivity -> "user", StaffActivity -> "staff"
    def self.infer_resource_type(audit_class, resource)
      # Try to extract from audit class name (UserActivity -> user)
      class_name = audit_class.name.demodulize
      if class_name =~ /^(\w+)Activity$/
        Regexp.last_match(1).downcase
      else
        # Fallback to resource class name
        resource.class.name.downcase
      end
    end

    private_class_method :infer_resource_type

    def self.normalize_event_id(audit_class, event_id)
      return event_id if event_id.is_a?(Integer)
      return event_id unless event_id.is_a?(String)

      event_class_name = audit_class.name.sub(/Activity\z/, "ActivityEvent")
      event_class = event_class_name.safe_constantize
      return event_id unless event_class
      return event_id unless event_class.const_defined?(event_id)

      event_class.const_get(event_id)
    end

    private_class_method :normalize_event_id
  end
end
