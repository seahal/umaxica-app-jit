# frozen_string_literal: true

# Enforces isolation mode for restricted sessions.
# Restricted sessions can only access /in/session and are blocked everywhere else.
module RestrictedSessionGuard
  extend ActiveSupport::Concern

  BLOCKED_MESSAGE = "きんそくじこうです"

  included do
    before_action :enforce_restricted_session_guard!
  end

  private

  def enforce_restricted_session_guard!
    current_resource if respond_to?(:current_resource, true)
    return unless respond_to?(:current_session_restricted?, true)
    return unless current_session_restricted?
    return if allowlisted_for_restricted_session?

    handle_restricted_session_block
  end

  def allowlisted_for_restricted_session?
    return false if restricted_session_expired?

    controller_path.end_with?("in/sessions")
  end

  def restricted_session_expired?
    session = current_session
    return false unless session&.restricted?

    expired = session.refresh_expires_at.present? && session.refresh_expires_at <= Time.current
    return false unless expired

    return true if session.revoked_at.present?

    TokenRecord.connected_to(role: :writing) do
      session.revoke!
    end

    Rails.event.notify(
      "session.restricted.expired",
      user_token_id: session.public_id,
      user_id: session.respond_to?(:user_id) ? session.user_id : nil,
    )

    true
  end

  def handle_restricted_session_block
    Rails.event.notify(
      "session.restricted.blocked_route",
      path: request.path,
      method: request.request_method,
      user_token_id: current_session&.public_id,
      user_id: current_session.respond_to?(:user_id) ? current_session.user_id : nil,
    )

    render plain: BLOCKED_MESSAGE, status: :locked
  end
end
