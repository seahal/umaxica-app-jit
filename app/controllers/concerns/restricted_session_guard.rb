# frozen_string_literal: true

# Enforces write restrictions for restricted sessions.
#
# When a user logs in and exceeds their session limit, they get a "restricted"
# session that only allows session management operations. This concern prevents
# write operations (POST/PUT/PATCH/DELETE) from controllers that include it.
#
# Usage:
#   include RestrictedSessionGuard
#
# The guard automatically skips:
#   - /in/session endpoints (session management itself)
#   - Read operations (GET, HEAD, OPTIONS)
#   - JSON API requests (handled separately)
#
# When a restricted user attempts a write operation, they are redirected
# to /in/session with an explanatory message.
module RestrictedSessionGuard
  extend ActiveSupport::Concern

  included do
    before_action :enforce_restricted_session_guard!
  end

  private

  def enforce_restricted_session_guard!
    return unless should_enforce_restricted_guard?

    # Check if current session is restricted
    return unless respond_to?(:current_session_restricted?, true)
    return unless current_session_restricted?

    handle_restricted_session_write
  end

  def should_enforce_restricted_guard?
    # Only enforce for write operations
    return false unless request.post? || request.put? || request.patch? || request.delete?

    # Skip for session management endpoints
    return false if controller_path.end_with?("in/sessions")

    # Skip for logout endpoints
    return false if controller_path.end_with?("/outs")

    # Skip for token refresh/check endpoints
    return false if controller_path.include?("edge/v1/token")

    true
  end

  def handle_restricted_session_write
    if request.format.json?
      render json: {
        error: "session_restricted",
        message: I18n.t("sign.app.in.session.restricted_write_blocked"),
        redirect_url: sign_app_in_session_path,
      }, status: :forbidden
    else
      redirect_to sign_app_in_session_path,
                  alert: I18n.t("sign.app.in.session.restricted_write_blocked")
    end
  end
end
