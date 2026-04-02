# typed: false
# frozen_string_literal: true

<<<<<<<< HEAD:app/lib/core/cookie_options.rb
module Core
========
# Main::CookieOptions delegates to Core::CookieOptions for backward compatibility
module Main
>>>>>>>> 98bd02f0f ([CheckPoint] renamimg from main to core.):app/lib/main/cookie_options.rb
  module CookieOptions
    def self.for(surface:, request:, same_site: nil, expires: nil, httponly: true, secure: nil, path: nil, domain: true)
      Core::CookieOptions.for(
        surface: surface,
        request: request,
        same_site: same_site,
        expires: expires,
        httponly: httponly,
<<<<<<<< HEAD:app/lib/core/cookie_options.rb
        secure: secure.nil? ? resolve_secure(request) : secure,
      }
      options[:same_site] = same_site if same_site
      options[:expires] = expires if expires
      options[:path] = path if path

      if domain
        cookie_domain = Core::CookieDomain.for(surface: surface, request_host: request.host)
        options[:domain] = cookie_domain if cookie_domain.present?
      end
      options
========
        secure: secure,
        path: path,
        domain: domain
      )
>>>>>>>> 98bd02f0f ([CheckPoint] renamimg from main to core.):app/lib/main/cookie_options.rb
    end
  end
end
