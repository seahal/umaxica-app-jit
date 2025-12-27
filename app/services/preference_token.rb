# frozen_string_literal: true

class PreferenceToken
  include PreferenceConstants

  ALGORITHM = ENV.fetch("PREFERENCE_JWT_ALGORITHM", "ES256")
  AUDIENCE = "preferences"
  EXPIRY = 1.year

  def self.encode(preferences, host:)
    payload = build_payload(preferences, host)
    JWT.encode(payload, PreferenceJwtConfig.private_key, ALGORITHM)
  rescue StandardError => e
    Rails.event.notify("preference_token.encode_failed",
                       error_class: e.class.name,
                       error_message: e.message,
                       host: host,)
    nil
  end

  def self.decode(token, host:)
    return nil if token.blank?

    JWT.decode(token, PreferenceJwtConfig.public_key, true, {
      algorithms: [ALGORITHM],
      verify_iat: true,
      verify_exp: true,
      verify_iss: true,
      iss: host,
      verify_aud: true,
      aud: AUDIENCE,
    }).first
  rescue JWT::ExpiredSignature
    Rails.event.notify("preference_token.decode_expired", host: host)
    nil
  rescue JWT::DecodeError, JWT::VerificationError => e
    Rails.event.notify("preference_token.decode_failed",
                       error_class: e.class.name,
                       host: host,)
    nil
  rescue StandardError => e
    Rails.event.notify("preference_token.decode_error",
                       error_class: e.class.name,
                       error_message: e.message,
                       host: host,)
    nil
  end

  def self.extract_preferences(payload)
    payload.to_h.transform_keys(&:to_s).slice(*PREFERENCE_KEYS)
  end

  def self.build_payload(preferences, host)
    extract_preferences(preferences).merge(
      iss: host,
      aud: AUDIENCE,
      iat: Time.current.to_i,
      exp: EXPIRY.from_now.to_i,
    )
  end

  private_class_method :build_payload
end
