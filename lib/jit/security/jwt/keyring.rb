# typed: false
# frozen_string_literal: true

require "base64"
require "openssl"
require "json"

module Jit
  module Security
    module Jwt
      module Keyring
        module_function

        def active_kid
          ENV.fetch("AUTH_JWT_ACTIVE_KID", "default")
        end

        def private_key_for_active
          private_key_for(active_kid)
        end

        def private_key_for(kid)
          keyset = parse_keyset(ENV["AUTH_JWT_PRIVATE_KEYSET"])
          return decode_key(keyset[kid]) if keyset.key?(kid)
          return Auth::Base::JwtConfiguration.private_key if kid == active_kid

          nil
        end

        def public_key_for(kid)
          keyset = parse_keyset(ENV["AUTH_JWT_PUBLIC_KEYSET"])
          return decode_key(keyset[kid]) if keyset.key?(kid)
          return Auth::Base::JwtConfiguration.public_key if kid == active_kid

          nil
        end

        def parse_header(token)
          _payload, header = JWT.decode(token, nil, false)
          header || {}
        rescue JWT::DecodeError
          {}
        end

        def parse_keyset(raw)
          return {} if raw.blank?

          parsed = JSON.parse(raw)
          return parsed if parsed.is_a?(Hash)

          {}
        rescue JSON::ParserError
          {}
        end

        def decode_key(base64_der)
          return nil if base64_der.blank?

          OpenSSL::PKey::EC.new(Base64.decode64(base64_der))
        rescue OpenSSL::PKey::PKeyError
          nil
        end
      end
    end
  end
end
