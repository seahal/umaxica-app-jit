# typed: false
# frozen_string_literal: true

module Auth
  module TokenClaims
    module_function

    VALID_SUBJECT_TYPES = %w(user staff customer).freeze
    VALID_ACR_VALUES = %w(aal1 aal2).freeze
    VALID_AMR_VALUES = %w(email_otp passkey apple google recovery_code totp).freeze

    def build(resource:, session_public_id:, resource_type:, issued_at:, access_token_ttl:, expires_at: nil,
              preferences: nil, scopes: nil, subject_type: nil, acr: nil, amr: nil)
      issued_at_seconds = timestamp_value(issued_at)
      expires_at_seconds = timestamp_value(expires_at || (issued_at + access_token_ttl))
      token_type = Authentication::Base::JwtConfiguration.token_type(resource_type)
      scopes_value = scopes || resolve_scopes(resource_type, resource)

      normalized_subject_type = normalize_subject_type(subject_type, resource_type)
      normalized_acr = normalize_acr(acr)
      normalized_amr = normalize_amr(amr)

      payload = {
        "iat" => issued_at_seconds,
        "exp" => expires_at_seconds,
        "jti" => Jit::Security::Jwt::JtiGenerator.generate,
        "sub" => resource.id,
        "act" => resource_type,
        "typ" => token_type,
        "iss" => Authentication::Base::JwtConfiguration.issuer(resource_type),
        "aud" => Authentication::Base::JwtConfiguration.audiences(resource_type),
        "scp" => scopes_value,
        "subject_type" => normalized_subject_type,
        "acr" => normalized_acr,
        "amr" => normalized_amr,
      }
      payload["sid"] = session_public_id if session_public_id.present?
      payload["prf"] = preferences if preferences.is_a?(Hash) && preferences.present?
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

    def preferences(payload)
      payload&.dig("prf")
    end

    def scopes(payload)
      payload&.dig("scp") || []
    end

    def audiences(payload)
      payload&.dig("aud") || []
    end

    def subject_type(payload)
      payload&.dig("subject_type")
    end

    def acr(payload)
      payload&.dig("acr")
    end

    def amr(payload)
      payload&.dig("amr") || []
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

    def resolve_scopes(resource_type, _resource)
      base_scopes = ["authenticated", "domain:#{resource_type}"]

      case resource_type.to_s
      when "user", "customer"
        base_scopes + ["read:self", "write:self"]
      when "staff"
        base_scopes + ["read:org", "write:org"]
      else
        base_scopes
      end
    end
    private_class_method :resolve_scopes

    def normalize_subject_type(subject_type, resource_type)
      return resource_type.to_s if subject_type.blank?

      subject_type = subject_type.to_s
      unless VALID_SUBJECT_TYPES.include?(subject_type)
        raise ArgumentError,
              "Invalid subject_type: #{subject_type.inspect}. Must be one of #{VALID_SUBJECT_TYPES.inspect}"
      end

      subject_type
    end
    private_class_method :normalize_subject_type

    def normalize_acr(acr)
      return "aal1" if acr.blank?

      acr = acr.to_s
      unless VALID_ACR_VALUES.include?(acr)
        raise ArgumentError, "Invalid acr: #{acr.inspect}. Must be one of #{VALID_ACR_VALUES.inspect}"
      end

      acr
    end
    private_class_method :normalize_acr

    def normalize_amr(amr)
      return [] if amr.blank?

      amr = Array(amr).map(&:to_s).compact_blank.uniq
      return [] if amr.empty?

      invalid_values = amr - VALID_AMR_VALUES
      if invalid_values.any?
        raise ArgumentError,
              "Invalid amr: #{invalid_values.inspect}. Must be drawn from #{VALID_AMR_VALUES.inspect}"
      end

      amr
    end
    private_class_method :normalize_amr
  end
end
