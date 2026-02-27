# typed: false
# frozen_string_literal: true

module Webauthn
  def self.trusted_origins
    # rubocop:disable ThreadSafety/ClassInstanceVariable
    @trusted_origins ||=
      begin
        # rubocop:enable ThreadSafety/ClassInstanceVariable
        map = JSON.parse(ENV.fetch("WEBAUTHN_RP_MAP", "{}"))
        origins = map.values.pluck("origin")

        # Add defaults for development/test environments
        if Rails.env.local?
          origins += [
            "http://localhost:3000",
            "http://127.0.0.1:3000",
            "https://sign.umaxica.app",
            "https://sign.umaxica.org",
            "http://sign.app.localhost:3000",
            "http://sign.org.localhost:3000",
          ]
        end

        origins.compact.uniq
      end
  end

  def self.validate_origin!(origin)
    unless trusted_origins.include?(origin)
      raise WebAuthn::OriginVerificationError, "Origin not trusted: #{origin}"
    end

    true
  end
end
