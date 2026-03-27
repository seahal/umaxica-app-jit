# typed: false
# frozen_string_literal: true

require_relative "../../app/controllers/concerns/authentication/base"
require_relative "../../app/controllers/concerns/authentication/user"
require_relative "../../app/controllers/concerns/authentication/staff"

# Helpers for authentication-related test setup.
#
# This app supports multiple "surfaces":
# - Edge API: Cookie-based auth (browser/SPA) + JSON 401 (no redirect)
# - Member API: Bearer auth (native/external) + JSON 401
#
# In tests, controllers can bypass auth via special headers:
# - "X-TEST-CURRENT-USER"
# - "X-TEST-CURRENT-STAFF"
#
# Prefer those headers for controller/integration tests to avoid coupling to
# token issuance and refresh flows.
module AuthHelpers
  TEST_USER_HEADER = "X-TEST-CURRENT-USER"
  TEST_STAFF_HEADER = "X-TEST-CURRENT-STAFF"
  MODERN_USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
                      "AppleWebKit/537.36 (KHTML, like Gecko) " \
                      "Chrome/120.0.0.0 Safari/537.36"

  def host_headers(host = nil)
    host_value =
      host ||
      (respond_to?(:request, true) ? request&.host : nil) ||
      ENV["DEFAULT_URL_HOST"]

    headers = { "User-Agent" => MODERN_USER_AGENT }
    headers["Host"] = host_value if host_value.present?
    headers
  end

  def browser_headers
    { "User-Agent" => MODERN_USER_AGENT }
  end

  def as_user_headers(user, host: nil, headers: {})
    base = host_headers(host).merge(headers).merge(TEST_USER_HEADER => user.id.to_s)

    if user.respond_to?(:persisted?) && user.persisted? && user.class.name == "User"
      token = UserToken.where(user_id: user.id, expired_at: nil).order(created_at: :desc).first
      token ||= UserToken.create!(user_id: user.id, user_token_kind_id: UserTokenKind::BROWSER_WEB)
      base["X-TEST-SESSION-PUBLIC-ID"] = token.public_id
    end

    base
  end

  def as_staff_headers(staff, host: nil, headers: {})
    host_headers(host).merge(headers).merge(TEST_STAFF_HEADER => staff.id.to_s)
  end

  def bearer_headers(token, host: nil, headers: {})
    host_headers(host).merge(headers).merge("Authorization" => "Bearer #{token}")
  end

  # Generates a JWT access token via Authentication::Base::Token.
  # Returns nil if JWT credentials are not configured.
  def jwt_access_token_for(resource, host: nil, session_public_id: nil, resource_type: nil)
    host_value = host || (respond_to?(:request, true) ? request&.host : nil) || "unknown"
    ::Authentication::Base::Token.encode(
      resource,
      host: host_value,
      session_public_id: session_public_id,
      resource_type: resource_type,
    )
  end

  # Convenience for Cookie-based auth simulations (Edge API).
  # Use together with existing controllers expecting cookies.
  # Cookie keys are now centralized in Authentication::Base
  def set_access_cookie(token)
    cookies[::Authentication::Base::ACCESS_COOKIE_KEY] = token
  end

  def set_refresh_cookie(token)
    cookies[::Authentication::Base::REFRESH_COOKIE_KEY] = token
  end

  def satisfy_user_verification(user_token)
    verification, raw_token = UserVerification.issue_for_token!(token: user_token)
    cookies[UserVerification.cookie_name] = raw_token
    verification
  end

  def satisfy_staff_verification(staff_token)
    verification, raw_token = StaffVerification.issue_for_token!(token: staff_token)
    cookies[StaffVerification.cookie_name] = raw_token
    verification
  end

  # Legacy aliases for backward compatibility
  alias_method :set_user_access_cookie, :set_access_cookie
  alias_method :set_staff_access_cookie, :set_access_cookie

  # Parse Set-Cookie header and extract cookies for follow-up requests
  # Returns a hash of cookie names to values
  def extract_cookies_from_response
    raw_header = response.headers["Set-Cookie"] || response.headers["set-cookie"]
    lines =
      case raw_header
      when Array
        raw_header
      when String
        raw_header.split("\n")
      else
        []
      end

    parsed = {}
    lines.each do |line|
      pair = line.to_s.split(";", 2).first
      name, value = pair.to_s.split("=", 2)
      next if name.blank?

      parsed[name] = CGI.unescape(value.to_s)
    end

    parsed
  end

  # Check if response has Set-Cookie for a specific cookie name
  def response_has_cookie?(name)
    raw_header = response.headers["Set-Cookie"] || response.headers["set-cookie"]
    lines =
      case raw_header
      when Array
        raw_header
      when String
        raw_header.split("\n")
      else
        []
      end

    lines.any? { |line| line.start_with?("#{name}=") }
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) { include AuthHelpers }
