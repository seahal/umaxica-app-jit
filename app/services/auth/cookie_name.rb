# typed: false
# frozen_string_literal: true

module Auth
  module CookieName
    module_function

    def access(production: Rails.env.production?)
      with_secure_prefix(Auth::IoKeys::Cookies::ACCESS_BASENAME, production: production)
    end

    def refresh(production: Rails.env.production?)
      with_secure_prefix(Auth::IoKeys::Cookies::REFRESH_BASENAME, production: production)
    end

    def dbsc(production: Rails.env.production?)
      with_secure_prefix(Auth::IoKeys::Cookies::DBSC_BASENAME, production: production)
    end

    def device(production: Rails.env.production?, refresh_cookie_key: nil)
      return refresh_cookie_key.sub(
        Auth::IoKeys::Cookies::REFRESH_BASENAME,
        Auth::IoKeys::Cookies::DEVICE_BASENAME,
      ) if refresh_cookie_key

      with_secure_prefix(Auth::IoKeys::Cookies::DEVICE_BASENAME, production: production)
    end

    def with_secure_prefix(basename, production:)
      return basename unless production || ENV["FORCE_SECURE_COOKIES"].present?

      "#{Auth::IoKeys::SECURE_COOKIE_PREFIX}#{basename}"
    end
    private_class_method :with_secure_prefix
  end
end
