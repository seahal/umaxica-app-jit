# frozen_string_literal: true

# Helper methods for working with cookies in integration tests
module CookieHelper
  # Read a signed cookie value by key
  # @param key [Symbol, String] The cookie key to read
  # @return [String, nil] The signed cookie value or nil if not found
  def signed_cookie(key)
    # Create a proper cookie jar using the request object
    cookie_jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
    cookie_jar.signed[key]
  end
end

# Include the helper in ActionDispatch::IntegrationTest
ActiveSupport.on_load(:action_dispatch_integration_test) { include CookieHelper }
