# frozen_string_literal: true

require "jwt"
require_relative "jwt_configuration"
require_relative "../../../models/concerns/preference_constants"

module Preference
  # Handles encoding and decoding of preference access tokens stored in cookies.
  # Note: Access tokens use asymmetric keys (private/public), so two keys are required.
  class Token
    include PreferenceConstants

    JWT_ALGORITHM = "ES256"
    ACCESS_TOKEN_TTL = 7.days

    class << self
      # Encode preferences into a signed JWT
      # @param preferences [Hash] Hash containing preference keys (lx, ri, tz, ct)
      # @param host [String] The host for which the token is valid
      # @param preference_type [String] The preference class name (AppPreference, ComPreference, etc.)
      # @param public_id [String] The public identifier for the preference record
      # @return [String, nil] The encoded token or nil if encoding fails
      def encode(preferences, host:, preference_type:, public_id:)
        return nil unless valid_encode_params?(preferences, host, preference_type, public_id)

        payload = build_payload(preferences, host, preference_type, public_id)
        JWT.encode(payload, JwtConfiguration.private_key, JWT_ALGORITHM)
      rescue StandardError => error
        Rails.logger.error("PreferenceToken.encode failed: #{error.message}")
        nil
      end

      # Decode a preference token
      # @param token [String] The encoded token
      # @param host [String] The host for validation
      # @return [Hash, nil] The decoded payload or nil if decoding fails
      def decode(token, host:)
        return nil if token.blank? || host.blank?

        payload, = JWT.decode(token, JwtConfiguration.public_key, true, decode_options)
        validate_payload(payload, host)
      rescue JWT::ExpiredSignature
        Rails.logger.debug("PreferenceToken.decode failed: token expired")
        nil
      rescue JWT::DecodeError => error
        Rails.logger.debug { "PreferenceToken.decode invalid token: #{error.message}" }
        nil
      rescue StandardError => error
        Rails.logger.error("PreferenceToken.decode failed: #{error.message}")
        nil
      end

      # Extract preferences from a decoded payload
      # @param payload [Hash] The decoded payload
      # @return [Hash] The preferences hash
      def extract_preferences(payload)
        return {} unless payload.is_a?(Hash)

        payload["preferences"] || {}
      end

      # Extract public_id value from decoded payload
      def extract_public_id(payload)
        payload&.dig("public_id")
      end

      # Extract preference_type value from decoded payload
      def extract_preference_type(payload)
        payload&.dig("preference_type")
      end

      private

      # Validation
      # ----------

      def valid_encode_params?(preferences, host, preference_type, public_id)
        [preferences, host, preference_type, public_id].all?(&:present?)
      end

      def validate_payload(payload, host)
        return nil unless payload.is_a?(Hash)
        return nil unless host_matches?(payload["host"], host)
        return nil unless audience_matches?(payload["aud"], host)

        payload
      end

      def host_matches?(host_claim, host)
        return false if host_claim.blank?

        host == host_claim || host.end_with?(".#{host_claim}")
      end

      def audience_matches?(aud_claim, host)
        normalize_audiences(aud_claim).any? do |aud|
          next false if aud.blank?

          host == aud || host.end_with?(".#{aud}")
        end
      end

      # Payload building
      # ----------------

      def build_payload(preferences, host, preference_type, public_id)
        {
          "preferences" => preferences.slice(*Preference::Constants::PREFERENCE_KEYS),
          "host" => host,
          "preference_type" => preference_type,
          "public_id" => public_id,
          # TODO: Add jti and track it in audit logs for token issuance/refresh.
          **jwt_claims,
        }
      end

      def jwt_claims
        now = Time.current

        {
          "iss" => JwtConfiguration.issuer,
          "aud" => resolve_audiences,
          "iat" => now.to_i,
          "exp" => (now + ACCESS_TOKEN_TTL).to_i,
        }
      end

      # JWT configuration
      # -----------------

      def decode_options
        {
          algorithms: [JWT_ALGORITHM],
          verify_iss: true,
          iss: JwtConfiguration.issuer,
        }
      end

      def resolve_audiences
        audiences = JwtConfiguration.audiences
        audiences.presence || []
      end

      def normalize_audiences(aud_claim)
        case aud_claim
        when Array then aud_claim
        when String then [aud_claim]
        else []
        end
      end
    end
  end
end
