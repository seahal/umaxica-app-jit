# typed: false
# frozen_string_literal: true

module Foundation
  module CookieOptions
    module_function

    def for(surface:, request:, same_site: nil, expires: nil, httponly: true, secure: nil, path: nil, domain: true)
      options = {
        httponly: httponly,
        secure: secure.nil? ? resolve_secure(request) : secure,
      }
      options[:same_site] = same_site if same_site
      options[:expires] = expires if expires
      options[:path] = path if path

      if domain
        cookie_domain = Foundation::CookieDomain.for(surface: surface, request_host: request.host)
        options[:domain] = cookie_domain if cookie_domain.present?
      end
      options
    end

    def resolve_secure(request)
      Rails.env.production? || ENV["FORCE_SECURE_COOKIES"].present? || request.ssl?
    end
    private_class_method :resolve_secure
  end
end
