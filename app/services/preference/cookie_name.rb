# frozen_string_literal: true

module Preference
  module CookieName
    module_function

    def access(production: Rails.env.production?)
      with_secure_prefix(Preference::IoKeys::Cookies::ACCESS_BASENAME, production: production)
    end

    def refresh(production: Rails.env.production?)
      with_secure_prefix(Preference::IoKeys::Cookies::REFRESH_BASENAME, production: production)
    end

    def device(production: Rails.env.production?, refresh_cookie_key: nil)
      return refresh_cookie_key.sub(
        Preference::IoKeys::Cookies::REFRESH_BASENAME,
        Preference::IoKeys::Cookies::DEVICE_BASENAME,
      ) if refresh_cookie_key

      with_secure_prefix(Preference::IoKeys::Cookies::DEVICE_BASENAME, production: production)
    end

    def with_secure_prefix(basename, production:)
      return basename unless production

      "#{Preference::IoKeys::SECURE_COOKIE_PREFIX}#{basename}"
    end
    private_class_method :with_secure_prefix
  end
end
