# typed: false
# frozen_string_literal: true

# Provides server-side session gating for concurrent session limit management.
# When a user exceeds their maximum concurrent sessions, they are redirected to
# a session management screen where they can revoke existing sessions.
#
# The gate uses server-side session storage with a 15-minute TTL and a nonce
# to prevent replay attacks and ensure one-time use.
#
# Usage in controllers:
#   include SessionLimitGate
#
#   # In login flow (when session limit exceeded):
#   issue_session_limit_gate!(return_to: request.fullpath, flow: "in.email.session")
#   redirect_to edit_sign_app_in_email_session_path
#
#   # In session management controller:
#   before_action :require_valid_gate
#
#   def edit
#     @active_sessions = current_user.user_tokens.active
#   end
#
#   def update
#     revoke_selected_sessions!
#     consume_session_limit_gate!
#     redirect_to session_limit_return_to
#   end
module SessionLimitGate
  extend ActiveSupport::Concern

  GATE_SESSION_KEY = :session_limit_gate
  GATE_TTL_SECONDS = 900 # 15 minutes

  # Issues a new session limit gate token.
  # This should be called when a user attempts to log in but exceeds their session limit.
  #
  # @param return_to [String] The path to return to after session management (must start with "/")
  # @param flow [String] Identifier for the authentication flow (e.g., "in.email.session")
  def issue_session_limit_gate!(return_to:, flow:)
    # Security: Only allow internal paths (must start with "/")
    safe_return_to = return_to.to_s.start_with?("/") ? return_to : nil

    session[GATE_SESSION_KEY] = {
      "nonce" => SecureRandom.hex(16),
      "issued_at" => Time.current.to_i,
      "return_to" => safe_return_to,
      "flow" => flow.to_s,
    }
  end

  # Validates that a valid, non-expired gate exists.
  # Use as a before_action in session management controllers.
  #
  # If the gate is missing or expired, redirects to the login page with an alert.
  #
  # @param login_path [String] The path to redirect to if the gate is invalid
  def require_session_limit_gate!(login_path:)
    gate = session[GATE_SESSION_KEY]

    unless valid_gate?(gate)
      session.delete(GATE_SESSION_KEY)
      flash[:alert] = I18n.t("session_limit.gate_expired", default: "操作がタイムアウトしました。もう一度ログインしてください。")
      redirect_to login_path
      return false
    end

    true
  end

  # Consumes (deletes) the session limit gate after successful session revocation.
  # This ensures the gate is single-use.
  def consume_session_limit_gate!
    session.delete(GATE_SESSION_KEY)
  end

  # Returns the return_to path from the gate, or nil if not set.
  # Used to redirect the user back to their original login flow after session management.
  #
  # @return [String, nil] The return path or nil
  def session_limit_return_to
    gate = session[GATE_SESSION_KEY]
    return nil unless gate.is_a?(Hash)

    return_to = gate["return_to"]
    # Security: Only allow internal paths
    return_to if return_to.to_s.start_with?("/")
  end

  # Returns the flow identifier from the gate.
  #
  # @return [String, nil] The flow identifier
  def session_limit_flow
    gate = session[GATE_SESSION_KEY]
    return nil unless gate.is_a?(Hash)

    gate["flow"]
  end

  # Checks if the gate is valid and not expired.
  #
  # @return [Boolean] true if the gate is valid
  def session_limit_gate_valid?
    valid_gate?(session[GATE_SESSION_KEY])
  end

  # Pre-checks if a resource would be hard-rejected by the session limit.
  # Use before authentication to avoid unnecessary work (e.g., sending OTP emails,
  # generating WebAuthn challenges, verifying secrets).
  #
  # @param resource [User, Staff] the resource to check
  # @return [Boolean] true if the resource is at the hard limit
  def session_limit_hard_reject_for?(resource)
    return false unless resource

    session_limit_state_for(resource) == :hard_reject
  end

  # Renders a hard reject response (409 Conflict) when the session limit is exceeded.
  # Handles both HTML and JSON formats.
  #
  # @param message [String, nil] Custom message (defaults to SESSION_LIMIT_HARD_REJECT_MESSAGE)
  # @param http_status [Symbol, nil] HTTP status (defaults to :conflict)
  def render_session_limit_hard_reject(message: nil, http_status: nil)
    msg = message || I18n.t("session_limit.login_limit_exceeded")
    status = http_status || :conflict

    respond_to do |format|
      format.html { render plain: msg, status: status }
      format.json { render json: { error: msg, error_code: "session_limit_hard_reject" }, status: status }
    end
  end

  private

  def valid_gate?(gate)
    return false unless gate.is_a?(Hash)
    return false if gate["nonce"].blank?
    return false if gate["issued_at"].blank?

    issued_at = gate["issued_at"].to_i
    expires_at = issued_at + GATE_TTL_SECONDS

    Time.current.to_i < expires_at
  end
end
