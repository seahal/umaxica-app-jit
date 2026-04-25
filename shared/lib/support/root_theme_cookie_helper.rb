# typed: false
# frozen_string_literal: true

module RootThemeCookieHelper
  def assert_theme_cookie_for(host:, path:, label:, **params)
    host!(host)

    url =
      begin
        public_send(path, **params)
      rescue NameError
        # Try common engine proxies
        engine =
          %i(distributor identity zenith foundation).find do |e|
            respond_to?(e) && public_send(e).respond_to?(path)
          end

        raise unless engine

        public_send(engine).public_send(path, **params)
      end

    get(url, headers: browser_headers)
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
