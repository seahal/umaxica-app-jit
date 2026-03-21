# typed: false
# frozen_string_literal: true

module Core
  module CookieOptions
    module_function

    def for(surface:, request:, same_site: nil, expires: nil, httponly: true, secure: nil, path: nil)
      options = {
        httponly: httponly,
        secure: secure.nil? ? (Rails.env.production? || request.ssl?) : secure,
      }
      options[:same_site] = same_site if same_site
      options[:expires] = expires if expires
      options[:path] = path if path

      domain = Core::CookieDomain.for(surface: surface, request_host: request.host)
      options[:domain] = domain if domain.present?
      options
    end
  end
end
