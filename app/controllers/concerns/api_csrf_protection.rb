# typed: false
# frozen_string_literal: true

module ApiCsrfProtection
  extend ActiveSupport::Concern

  included do
    before_action :check_csrf_origin
  end

  private

  def check_csrf_origin
    # GET/HEAD requests are safe; skip origin check
    return if request.get? || request.head?

    origin = request.headers["Origin"]

    # Allow blank Origin.
    # Reason: Some clients or same-origin requests may not send the Origin header.
    # We rely on the standard CSRF token verification (secure_compare) as the primary defense.
    return if origin.blank?

    handle_invalid_origin unless valid_csrf_origin?(origin)
  end

  def valid_csrf_origin?(origin)
    uri = URI.parse(origin)
    return false unless uri.scheme.in?(%w(http https))

    # Normalize hosts for comparison
    origin_host = uri.host&.downcase
    request_host = request.host.downcase

    # (B) Origin Check: Option 1 (Strict Match)
    # Only allow exact match with request host.
    # Subdomains are NOT allowed by default to prevent subdomain takeover attacks.
    # If subdomains are needed, use an explicit allowlist instead of `end_with?`.
    origin_host == request_host
  rescue URI::InvalidURIError
    false
  end

  def handle_invalid_origin
    Rails.logger.warn "CSRF Origin Mismatch: Origin=#{request.headers["Origin"]} RequestHost=#{request.host}"
    raise ActionController::InvalidCrossOriginRequest, "CSRF Origin Mismatch"
  end
end
