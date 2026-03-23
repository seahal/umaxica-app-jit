# typed: false
# frozen_string_literal: true

module Auth
  module TokenClaims
    module_function

    def build(resource:, session_public_id:, resource_type:, issued_at:, access_token_ttl:, expires_at: nil,
              preference: nil)
      issued_at_seconds = timestamp_value(issued_at)
      expires_at_seconds = timestamp_value(expires_at || (issued_at + access_token_ttl))
      token_type = Auth::Base::JwtConfiguration.token_type(resource_type)
      payload = {
        "iat" => issued_at_seconds,
        "nbf" => issued_at_seconds,
        "exp" => expires_at_seconds,
        "jti" => Jit::Security::Jwt::JtiGenerator.generate,
        "sub" => resource.id,
        "act" => resource_type,
        "typ" => token_type,
        "iss" => Auth::Base::JwtConfiguration.issuer(resource_type),
        "aud" => Auth::Base::JwtConfiguration.audiences(resource_type),
      }
      payload["sid"] = session_public_id if session_public_id.present?
      if preference.present?
        payload["prf"] = {
          "lx" => preference[:language] || preference["lx"],
          "ri" => preference[:region] || preference["ri"],
          "tz" => preference[:timezone] || preference["tz"],
          "ct" => preference[:theme] || preference["ct"],
        }.compact
      end
      payload
    end

    def subject(payload)
      payload&.dig("sub")
    end

    def actor(payload)
      payload&.dig("act")
    end

    def session_id(payload)
      payload&.dig("sid")
    end

    def jti(payload)
      payload&.dig("jti")
    end

    def preference(payload)
      payload&.dig("prf")
    end

    def timestamp_value(value)
      if value.is_a?(Time) || value.is_a?(ActiveSupport::TimeWithZone)
        return Integer(value.strftime("%s"), 10)
      end

      return value if value.is_a?(Integer)
      return Integer(value, 10) if value.is_a?(Numeric)

      Integer(value.to_s, 10)
    end
    private_class_method :timestamp_value
  end
end
