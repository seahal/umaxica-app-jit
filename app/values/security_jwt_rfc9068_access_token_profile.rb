# typed: false
# frozen_string_literal: true

# Shared RFC 9068 access-token header and claim-type policy for first-party
# auth_access and preference_access tokens (and OIDC access tokens that share
# the auth codec).
#
# UMAXICA follows RFC 9068 token structure, claims, semantics, and validation
# with one documented interoperability deviation: ES384 is the only supported
# signing algorithm, and RS256 is intentionally not implemented.
module SecurityJwtRfc9068AccessTokenProfile
  ALGORITHM = "ES384"
  TOKEN_TYPE = "at+jwt"
  REQUIRED_CLAIMS = %w(iss exp aud sub client_id iat jti).freeze
  ACTOR_SCOPE_PREFIX = "domain:"

  module_function

  def header_valid?(header)
    return false unless header.is_a?(Hash)
    return false unless header["alg"] == ALGORITHM
    return false unless header["typ"] == TOKEN_TYPE
    return false if header["kid"].blank?

    true
  end

  def header_rejection_reason(header)
    return "MALFORMED_TOKEN" if header.blank? || !header.is_a?(Hash) || header["alg"].blank?
    return "MISSING_KID" if header["kid"].blank?
    return "ALG_NONE" if header["alg"] == "none"
    return "ALG_MISMATCH" if header["alg"] != ALGORITHM
    return "MISSING_TYP" if header["typ"].blank?
    return "TYP_MISMATCH" if header["typ"] != TOKEN_TYPE

    "INVALID_HEADER"
  end

  def claims_structurally_valid?(payload)
    return false unless payload.is_a?(Hash)
    return false unless REQUIRED_CLAIMS.all? { |claim| payload.key?(claim) }
    return false unless payload["sub"].is_a?(String) && payload["sub"].present?
    return false unless payload["client_id"].is_a?(String) && payload["client_id"].present?
    return false unless payload["iss"].is_a?(String) && payload["iss"].present?
    return false unless payload["jti"].is_a?(String) && payload["jti"].present?
    return false unless integer_time?(payload["iat"])
    return false unless integer_time?(payload["exp"])
    return false unless audience_valid?(payload["aud"])
    return false unless scope_valid?(payload["scope"])
    return false if payload.key?("nbf") && !integer_time?(payload["nbf"])
    return false if payload.key?("scp")
    return false if payload.key?("typ")
    return false if payload.key?("act")

    true
  end

  def parse_scopes(payload)
    return [] unless payload.is_a?(Hash)

    case payload["scope"]
    when String
      payload["scope"].split
    else
      []
    end
  end

  def actor_type_from_scope(payload)
    parse_scopes(payload).filter_map do |scope|
      next unless scope.start_with?(ACTOR_SCOPE_PREFIX)

      scope.delete_prefix(ACTOR_SCOPE_PREFIX).presence
    end.uniq.then { |types| types.one? ? types.first : nil }
  end

  def integer_time?(value)
    value.is_a?(Integer)
  end
  private_class_method :integer_time?

  def audience_valid?(aud)
    case aud
    when String then aud.present?
    when Array then aud.any? && aud.all? { |value| value.is_a?(String) && value.present? }
    else false
    end
  end
  private_class_method :audience_valid?

  def scope_valid?(scope)
    return true if scope.nil?
    return false unless scope.is_a?(String)

    true
  end
  private_class_method :scope_valid?
end
