# typed: false
# frozen_string_literal: true

module RootThemeCookieHelper
  def assert_theme_cookie_for(host:, path:, label:, **params)
    host!(host)
    get public_send(path, **params), headers: browser_headers
    follow_redirect! if response.redirect?
    assert_response :success

    token = cookies["jit_preference_access"]
    assert_not_nil token, "#{label} should set cookies[jit_preference_access]"

    cookies.delete("jit_preference_access")
  end
end
