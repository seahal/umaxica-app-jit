# frozen_string_literal: true

# CSRF protection for API endpoints (JSON-based)
# Validates X-CSRF-Token header and Origin/Referer on state-changing requests
module ApiCsrfProtection
  extend ActiveSupport::Concern

  PROTECTED_METHODS = %w(POST PUT PATCH DELETE).freeze

  included do
    before_action :validate_api_csrf_token,
                  if: :should_validate_api_csrf?
  end

  private

  def should_validate_api_csrf?
    # Only validate for API requests (JSON)
    return false unless request.format.json?

    # Only validate state-changing methods
    PROTECTED_METHODS.include?(request.method)
  end

  def validate_api_csrf_token
    # Extract token from X-CSRF-Token header
    token_from_header = request.headers["X-CSRF-Token"]

    # Get the session CSRF token (Rails sets this automatically)
    # For SPA requests, compare token from header with session token
    session_token = session["_csrf_token"]

    # Also check Origin/Referer
    if !validate_request_origin
      Rails.logger.warn "[CSRF] Invalid origin for API request: #{request.origin}"
      render json: { error: "invalid_origin" }, status: :forbidden
      return
    end

    # Validate token
    unless token_from_header.present? &&
        session_token.present? &&
        ActiveSupport::SecurityUtils.secure_compare(token_from_header, session_token)
      Rails.logger.warn "[CSRF] Invalid CSRF token for API request"
      render json: { error: "invalid_csrf_token" }, status: :forbidden
    end
  end

  def validate_request_origin
    # Check Origin header (preferred)
    origin = request.origin
    return true if origin.blank? # No origin = same-origin (browser limitation)

    # Parse origin
    origin_uri = URI.parse(origin)
    origin_host = origin_uri.host

    # Check against request host and configured allowed hosts
    request_host = request.host

    # Allow same-origin
    origin_host == request_host || origin_host.end_with?(".#{request_host}")
  end
end
