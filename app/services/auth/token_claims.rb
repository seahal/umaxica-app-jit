# typed: false
# frozen_string_literal: true

module Auth
  module TokenClaims
    module_function

    def build(resource:, session_public_id:, resource_type:, issued_at:, access_token_ttl:, expires_at: nil)
      token_type = Auth::Base::JwtConfiguration.token_type(resource_type)
      payload = {
        "iat" => issued_at.to_i,
        "nbf" => issued_at.to_i,
        "exp" => (expires_at || (issued_at + access_token_ttl)).to_i,
        "jti" => Jit::Security::Jwt::JtiGenerator.generate,
        "sub" => resource.id,
        "act" => resource_type,
        "typ" => token_type,
        "iss" => Auth::Base::JwtConfiguration.issuer(resource_type),
        "aud" => Auth::Base::JwtConfiguration.audiences(resource_type),
      }
      payload["sid"] = session_public_id if session_public_id.present?
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
  end
end
