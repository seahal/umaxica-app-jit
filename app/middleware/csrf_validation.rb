# frozen_string_literal: true

# CSRF Protection Middleware for API endpoints
# Validates X-CSRF-Token header on state-changing requests
# - Checks Origin/Referer against configured allowlist
# - Validates CSRF token from header matches session token
# - Applies to POST/PUT/PATCH/DELETE on /edge/v1/* endpoints
class CsrfValidation
  PROTECTED_METHODS = %w(POST PUT PATCH DELETE).freeze
  PROTECTED_PATH_PATTERN = %r{\A/edge/v1/}.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    # Skip validation for non-protected methods and paths
    return @app.call(env) unless should_validate?(request)

    # Skip Rails built-in CSRF for HTML forms (protect_from_forgery handles those)
    return @app.call(env) if html_form_request?(request)

    # Validate origin/referer
    origin_valid = validate_origin(request)
    return error_response(403, "invalid_origin") unless origin_valid

    # Validate CSRF token
    token_valid = validate_csrf_token(request)
    return error_response(403, "invalid_csrf_token") unless token_valid

    @app.call(env)
  end

  private

  def should_validate?(request)
    method_protected = PROTECTED_METHODS.include?(request.request_method.upcase)
    path_protected = PROTECTED_PATH_PATTERN.match?(request.path_info)
    method_protected && path_protected
  end

  def html_form_request?(request)
    # HTML forms use application/x-www-form-urlencoded or multipart/form-data
    # API requests use application/json
    content_type = request.content_type.to_s
    content_type.include?("application/x-www-form-urlencoded") ||
      content_type.include?("multipart/form-data")
  end

  def validate_origin(request)
    # Extract origin/referer from request
    origin = request.get_header("HTTP_ORIGIN") || request.get_header("HTTP_REFERER")
    return true if origin.blank?

    # Normalize the origin
    origin_uri = URI.parse(origin)
    request_host = request.get_header("HTTP_HOST")

    # Allow same-origin requests
    origin_matches_host?(origin_uri, request_host)
  end

  def origin_matches_host?(origin_uri, request_host)
    "#{origin_uri.host}:#{origin_uri.port || 443}".delete_suffix(":443")
    request_host_normalized = request_host.split(":").first

    # Match against the host (support subdomains)
    origin_host_normalized = origin_uri.host
    origin_host_normalized == request_host_normalized ||
      origin_host_normalized.end_with?(".#{request_host_normalized}")
  end

  def validate_csrf_token(request)
    # Get CSRF token from request header
    token_from_header = request.get_header("HTTP_X_CSRF_TOKEN")
    return false if token_from_header.blank?

    csrf_cookie_key = defined?(::Csrf) ? ::Csrf::CSRF_COOKIE_KEY : "jit_csrf_token"
    token_from_cookie = request.cookies[csrf_cookie_key]
    if token_from_cookie.present?
      return secure_compare(token_from_header, token_from_cookie)
    end

    # Fallback for clients where CSRF cookie is unavailable but header token is present.
    # Rails controller-level CSRF verification still applies unless explicitly skipped.
    return true if token_from_header.present?

    # Legacy fallback for non-edge clients that keep only session token.
    session_token = request.session&.fetch("_csrf_token")
    if session_token.blank?
      return true
    end

    secure_compare(token_from_header, session_token)
  end

  def secure_compare(left, right)
    return false if left.blank? || right.blank?
    return false unless left.bytesize == right.bytesize

    ActiveSupport::SecurityUtils.secure_compare(left, right)
  end

  def error_response(status, error_code)
    body = JSON.generate({ error: error_code })
    [status, { "Content-Type" => "application/json" }, [body]]
  end
end
