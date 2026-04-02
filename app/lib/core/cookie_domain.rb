# typed: false
# frozen_string_literal: true

<<<<<<<< HEAD:app/lib/core/cookie_domain.rb
module Core
========
# Main::CookieDomain delegates to Core::CookieDomain for backward compatibility
module Main
>>>>>>>> 98bd02f0f ([CheckPoint] renamimg from main to core.):app/lib/main/cookie_domain.rb
  module CookieDomain
    def self.for(surface:, request_host:)
      Core::CookieDomain.for(surface: surface, request_host: request_host)
    end
<<<<<<<< HEAD:app/lib/core/cookie_domain.rb

    def normalize_configured(value)
      return nil if value.blank?

      normalized = normalize_host(value)
      return nil if normalized.blank? || normalized == HOST_ONLY
      return value if value.start_with?(".")
      return localhost_cookie_domain(normalized) if localhost_host?(normalized)

      apex = best_effort_apex(normalized)
      apex ? ".#{apex}" : nil
    end
    private_class_method :normalize_configured

    def derive_from_host(request_host)
      host = normalize_host(request_host)
      return nil if host.blank? || host == "localhost"
      return localhost_cookie_domain(host) if localhost_host?(host)

      apex = best_effort_apex(host)
      apex ? ".#{apex}" : nil
    end
    private_class_method :derive_from_host

    def normalize_host(value)
      Core::HostNormalization.normalize(value)
    end
    private_class_method :normalize_host

    def localhost_host?(host)
      host == "localhost" || host.end_with?(".localhost")
    end
    private_class_method :localhost_host?

    def localhost_cookie_domain(host)
      return nil if host == "localhost"

      parts = host.split(".")
      return nil if parts.length < 2

      ".#{parts.last(2).join(".")}"
    end
    private_class_method :localhost_cookie_domain

    # SECURITY NOTE: Scoping cookies to the apex domain (e.g., ".example.com") is intentional
    # for cross-subdomain SSO. This means auth cookies are readable by ALL subdomains.
    # Accepted risk: an XSS on any subdomain could access auth cookies (mitigated by httponly).
    # A subdomain compromise would expose session tokens for all services on the same apex.
    def best_effort_apex(host)
      parts = host.split(".")
      return nil if parts.length < 2

      parts.last(2).join(".")
    end
    private_class_method :best_effort_apex
========
>>>>>>>> 98bd02f0f ([CheckPoint] renamimg from main to core.):app/lib/main/cookie_domain.rb
  end
end
