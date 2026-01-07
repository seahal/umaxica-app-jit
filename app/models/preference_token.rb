# frozen_string_literal: true

# Handles encoding and decoding of preference tokens
# These tokens are stored in cookies and contain user preferences like language, region, timezone, and theme
class PreferenceToken
  include PreferenceConstants

  # Encode preferences into a JWT-like token
  # @param preferences [Hash] Hash containing preference keys (lx, ri, tz, ct)
  # @param host [String] The host for which the token is being created
  # @return [String, nil] The encoded token or nil if encoding fails
  def self.encode(preferences, host:)
    return nil if preferences.blank? || host.blank?

    payload = {
      "preferences" => preferences.slice(*PREFERENCE_KEYS),
      "host" => host,
      "iat" => Time.current.to_i,
    }

    # Use Rails message verifier for secure encoding
    verifier.generate(payload)
  rescue StandardError => error
    Rails.logger.error("PreferenceToken.encode failed: #{error.message}")
    nil
  end

  # Decode a preference token
  # @param token [String] The encoded token
  # @param host [String] The host for validation
  # @return [Hash, nil] The decoded payload or nil if decoding fails
  def self.decode(token, host:)
    return nil if token.blank? || host.blank?

    payload = verifier.verify(token)
    return nil unless payload.is_a?(Hash)
    return nil if payload["host"] != host

    payload
  rescue ActiveSupport::MessageVerifier::InvalidSignature => error
    Rails.logger.debug { "PreferenceToken.decode invalid signature: #{error.message}" }
    nil
  rescue StandardError => error
    Rails.logger.error("PreferenceToken.decode failed: #{error.message}")
    nil
  end

  # Extract preferences from a decoded payload
  # @param payload [Hash] The decoded payload
  # @return [Hash] The preferences hash
  def self.extract_preferences(payload)
    return {} unless payload.is_a?(Hash)

    payload["preferences"] || {}
  end

  # Get the message verifier for encoding/decoding
  # @return [ActiveSupport::MessageVerifier]
  def self.verifier
    ActiveSupport::MessageVerifier.new(
      Rails.application.secret_key_base,
      digest: "SHA256",
      serializer: JSON,
    )
  end
end
