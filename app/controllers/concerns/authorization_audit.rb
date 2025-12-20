# frozen_string_literal: true

# Concern for auditing authorization failures
# Records when users/staff attempt unauthorized actions
module AuthorizationAudit
  extend ActiveSupport::Concern

  included do
    # Log authorization failures for audit purposes
    rescue_from Pundit::NotAuthorizedError, with: :handle_authorization_error
  end

  private

  def handle_authorization_error(exception)
    # Log the authorization failure
    log_authorization_failure(exception)

    # Respond based on request format
    respond_to do |format|
      format.html do
        flash[:alert] = I18n.t("errors.messages.not_authorized")
        redirect_back_or_to(root_path)
      end
      format.json do
        render json: { error: "Unauthorized" }, status: :forbidden
      end
    end
  end

  def log_authorization_failure(exception)
    actor = current_user_or_staff
    return unless actor

    log_data = {
      actor_type: actor.class.name,
      actor_id: actor.id,
      action: action_name,
      controller: controller_name,
      policy: exception.policy.class.name,
      query: exception.query,
      record_type: exception.record&.class&.name,
      record_id: exception.record&.id,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      timestamp: Time.current
    }

    # Log the authorization failure event
    Rails.event.notify("authorization.failure", log_data)

    # Create audit record if actor is User or Staff
    if actor.is_a?(User)
      create_user_authorization_audit(actor, log_data)
    elsif actor.is_a?(Staff)
      create_staff_authorization_audit(actor, log_data)
    end
  rescue StandardError => e
    # Don't let audit logging break the application
    Rails.event.notify("authorization.failure_log.failed", error_message: e.message)
  end

  def create_user_authorization_audit(user, log_data)
    UserIdentityAudit.create!(
      user: user,
      actor: user,
      event_id: "AUTHORIZATION_FAILED",
      ip_address: log_data[:ip_address],
      timestamp: log_data[:timestamp]
    )
  rescue ActiveRecord::RecordInvalid => e
    # Event ID might not exist in the database yet
    Rails.event.notify("authorization.audit.user_creation_failed", error_message: e.message)
  end

  def create_staff_authorization_audit(staff, log_data)
    StaffIdentityAudit.create!(
      staff: staff,
      actor: staff,
      event_id: "AUTHORIZATION_FAILED",
      ip_address: log_data[:ip_address],
      timestamp: log_data[:timestamp]
    )
  rescue ActiveRecord::RecordInvalid => e
    # Event ID might not exist in the database yet
    Rails.event.notify("authorization.audit.staff_creation_failed", error_message: e.message)
  end

  def current_user_or_staff
    # Try current_user first (for User controllers)
    return current_user if respond_to?(:current_user) && current_user

    # Try current_staff (for Staff controllers)
    return current_staff if respond_to?(:current_staff) && current_staff

    nil
  end
end
