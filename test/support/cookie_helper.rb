# frozen_string_literal: true

# Helper methods for working with cookies in integration tests
module CookieHelper
  def preference_refresh_cookie_name
    Rails.env.production? ? "__Secure-jit_preference_refresh" : "jit_preference_refresh"
  end

  def preference_access_cookie_name
    Rails.env.production? ? "__Secure-jit_preference_access" : "jit_preference_access"
  end

  def preference_device_id_cookie_name
    preference_refresh_cookie_name.sub("jit_preference_refresh", "jit_preference_device_id")
  end

  # Read a signed cookie value by key
  # @param key [Symbol, String] The cookie key to read
  # @return [String, nil] The signed cookie value or nil if not found
  def signed_cookie(key)
    # Create a proper cookie jar using the request object
    cookie_jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
    cookie_jar.signed[key]
  end

  def preference_cookie_payload(key, host: request&.host)
    token = cookies[key]
    return nil if token.blank?

    Preference::Token.decode(token, host: host.to_s.presence || "unknown")
  end

  def response_cookie_expiry(name)
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

    cookie_line = lines.find { |line| line.start_with?("#{name}=") }
    return nil unless cookie_line

    match = cookie_line.match(/expires=([^;]+)/i)
    return nil unless match

    Time.httpdate(match[1])
  rescue ArgumentError
    nil
  end
end

# Include the helper in ActionDispatch::IntegrationTest
ActiveSupport.on_load(:action_dispatch_integration_test) { include CookieHelper }
