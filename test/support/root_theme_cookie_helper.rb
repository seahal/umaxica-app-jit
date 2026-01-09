# frozen_string_literal: true

module RootThemeCookieHelper
  def assert_theme_cookie_for(host:, path:, label:)
    host!(host)
    get public_send(path)
    assert_response :success
    assert_not_nil cookies[:ct], "#{label} should set cookies[:ct]"
    cookies.delete(:ct)
  end
end
