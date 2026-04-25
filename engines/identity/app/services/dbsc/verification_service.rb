# typed: false
# frozen_string_literal: true

module Dbsc
  class VerificationService < ApplicationService
    ALLOWED_ALGORITHMS = %w(ES256 RS256).freeze
    CHALLENGE_TTL = 5.minutes
    IAT_LEEWAY = 30.seconds

    def initialize(record:, session_id:, proof:, now: Time.current, expected_audience: nil)
      super
      @record = record
      @session_id = HeaderParser.string_value(session_id)
      @proof = HeaderParser.string_value(proof)
      @now = now
      @expected_audience = expected_audience
    end

    def call
      return failure("record_missing") if record.blank?
      return failure("missing_session_id") if session_id.blank?
      return failure("missing_proof") if proof.blank?
      return failure("registration_incomplete") if record.dbsc_session_id.to_s.blank?
      return failure("session_id_mismatch") unless record.dbsc_session_id == session_id
      return failure("missing_public_key") if record.dbsc_public_key.blank?
      return failure("missing_challenge") if record.dbsc_challenge.to_s.blank?
      return failure("challenge_expired") if challenge_expired?

      unverified_payload, unverified_header = JWT.decode(proof, nil, false)
      return failure("invalid_type") unless unverified_header["typ"].to_s == "dbsc+jwt"
      return failure("invalid_algorithm") unless ALLOWED_ALGORITHMS.include?(unverified_header["alg"].to_s)
      return failure("missing_audience") if unverified_payload["aud"].to_s.blank?
      return failure("audience_mismatch") if expected_audience.present? &&
        unverified_payload["aud"] != expected_audience
      return failure("missing_issued_at") unless unverified_payload["iat"].is_a?(Numeric)

      issued_at = Time.zone.at(unverified_payload["iat"])
      return failure("issued_at_future") if issued_at > now + IAT_LEEWAY
      return failure("issued_at_expired") if issued_at < now - CHALLENGE_TTL
      return failure("unexpected_public_key") if unverified_header["jwk"].present?
      return failure("challenge_mismatch") unless unverified_payload["jti"].to_s == record.dbsc_challenge.to_s

      JWT.decode(proof, RecordAdapter.dbsc_public_key(record), true, algorithms: [unverified_header["alg"]])

      { ok: true, record: record }
    rescue JWT::DecodeError, JWT::JWKError, JSON::ParserError, ArgumentError => e
      failure("invalid_proof", message: e.message)
    end

    private

    attr_reader :record, :session_id, :proof, :now, :expected_audience

    def challenge_expired?
      record.dbsc_challenge_issued_at.blank? || record.dbsc_challenge_issued_at < now - CHALLENGE_TTL
    end

    def failure(error_code, message: nil)
      { ok: false, error_code: error_code, message: message }
    end
  end
end
