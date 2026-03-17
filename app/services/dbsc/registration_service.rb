# typed: false
# frozen_string_literal: true

module Dbsc
  class RegistrationService < ApplicationService
    ALLOWED_ALGORITHMS = %w(ES256 RS256).freeze
    CHALLENGE_TTL = 5.minutes
    IAT_LEEWAY = 30.seconds

    def initialize(record:, proof:, now: Time.current, session_id: nil, expected_audience: nil)
      super
      @record = record
      @proof = HeaderParser.string_value(proof)
      @now = now
      @session_id = session_id.presence || record&.dbsc_session_id.presence || SecureRandom.urlsafe_base64(24)
      @expected_audience = expected_audience
    end

    def call
      return failure("record_missing") if record.blank?
      return failure("missing_proof") if proof.blank?
      return failure("missing_challenge") if record.dbsc_challenge.to_s.blank?

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

      jwk = RecordAdapter.normalize_public_key(unverified_header["jwk"])
      return failure("missing_public_key") if jwk.blank?
      return failure("challenge_mismatch") unless unverified_payload["jti"].to_s == record.dbsc_challenge.to_s

      verify_key = JWT::JWK.import(jwk).public_key
      JWT.decode(proof, verify_key, true, algorithms: [unverified_header["alg"]])

      record.with_lock do
        record.update!(
          RecordAdapter.binding_method_attribute(record) => RecordAdapter.binding_method_class(record)::DBSC,
          RecordAdapter.dbsc_status_attribute(record) => RecordAdapter.dbsc_status_class(record)::ACTIVE,
          :dbsc_session_id => session_id,
          :dbsc_public_key => jwk,
          :dbsc_challenge => nil,
          :dbsc_challenge_issued_at => nil,
        )
      end

      { ok: true, session_id: session_id, record: record }
    rescue JWT::DecodeError, JWT::JWKError, JSON::ParserError, ArgumentError => e
      failure("invalid_proof", message: e.message)
    end

    private

    attr_reader :record, :proof, :now, :session_id, :expected_audience

    def failure(error_code, message: nil)
      { ok: false, error_code: error_code, message: message }
    end
  end
end
