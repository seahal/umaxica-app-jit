# typed: false
# frozen_string_literal: true

module RootThemeCookieHelper
  def assert_theme_cookie_for(host:, path:, label:, **params)
    host!(host)
    get public_send(path, **params), headers: browser_headers
    follow_redirect! if response.redirect?

    assert_response :success

    token = cookies["preference_access"]

    assert_not_nil token, "#{label} should set cookies[preference_access]"

    # Validate the token is a decodable JWT (3 dot-separated base64 segments)
    segments = token.split(".")

    assert_equal 3, segments.size,
                 "#{label}: preference_access cookie should be a valid JWT (got #{segments.size} segments)"

    cookies.delete("preference_access")
  end
end
