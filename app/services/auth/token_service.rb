# frozen_string_literal: true

require "jwt"

module Auth
  class TokenService
    JWT_ALGORITHM = "ES384"
    VALID_ACTOR_TYPES = %w(user staff).freeze

    class << self
      def encode(resource, host:, session_public_id: nil, resource_type: nil)
        return nil unless valid_encode_params?(resource, host)

        type = resource_type || resource.class.name.downcase
        payload = build_payload(resource, session_public_id, type)
        JWT.encode(
          payload,
          Jit::Security::Jwt::Keyring.private_key_for_active,
          JWT_ALGORITHM,
          { kid: Jit::Security::Jwt::Keyring.active_kid },
        )
      rescue JWT::EncodeError, OpenSSL::PKey::PKeyError, ArgumentError => error
        Rails.event.notify(
          "authentication.token.generation.failed",
          error_class: error.class.name,
          error_message: error.message,
          backtrace: error.backtrace.first(5),
          resource_type: resource.class.name,
          resource_id: resource.id,
        )
        nil
      end

      def decode(token, host:, issuer: nil, audiences: nil)
        return nil if token.blank? || host.blank?

        header = Jit::Security::Jwt::Keyring.parse_header(token)
        return nil unless valid_header?(header)

        public_key = Jit::Security::Jwt::Keyring.public_key_for(header["kid"])
        return nil if public_key.nil?

        payload, = JWT.decode(token, public_key, true, decode_options(issuer, audiences))
        payload
      rescue JWT::ExpiredSignature
        Rails.event.notify("authentication.token.verification.expired", host: host)
        nil
      rescue JWT::DecodeError, JWT::VerificationError => error
        Rails.event.notify(
          "authentication.token.verification.failed",
          error_class: error.class.name,
          host: host,
        )
        nil
      rescue OpenSSL::PKey::PKeyError, ArgumentError, TypeError => error
        Rails.event.notify(
          "authentication.token.verification.error",
          error_class: error.class.name,
          error_message: error.message,
          host: host,
        )
        nil
      end

      def extract_subject(payload)
        Auth::TokenClaims.subject(payload)
      end

      def extract_act(payload)
        Auth::TokenClaims.actor(payload)
      end

      def extract_type(payload)
        extract_act(payload)
      end

      def extract_session_id(payload)
        Auth::TokenClaims.session_id(payload)
      end

      def extract_jti(payload)
        Auth::TokenClaims.jti(payload)
      end

      def validate_actor_claim!(payload, expected_act)
        return false if payload.blank?

        act = extract_act(payload)
        return false if act.blank?
        return false unless VALID_ACTOR_TYPES.include?(act)

        act == expected_act
      end

      private

      def valid_encode_params?(resource, host)
        return false if resource.nil? || host.blank?
        return false unless resource.respond_to?(:id)
        return false if resource.id.blank?

        true
      end

      def build_payload(resource, session_public_id, type)
        Auth::TokenClaims.build(
          resource: resource,
          session_public_id: session_public_id,
          resource_type: type,
          issued_at: Time.current,
          access_token_ttl: Auth::Base::ACCESS_TOKEN_TTL,
        ).merge(
          "iss" => Auth::Base::JwtConfiguration.issuer,
          "aud" => Auth::Base::JwtConfiguration.audiences,
        )
      end

      def decode_options(issuer, audiences)
        {
          algorithms: [JWT_ALGORITHM],
          verify_iat: true,
          verify_exp: true,
          verify_iss: true,
          iss: issuer || Auth::Base::JwtConfiguration.issuer,
          verify_aud: true,
          aud: audiences || Auth::Base::JwtConfiguration.audiences,
        }
      end

      def valid_header?(header)
        return false if header.blank?
        return false unless header["alg"] == JWT_ALGORITHM

        header["kid"].present?
      end
    end
  end
end
