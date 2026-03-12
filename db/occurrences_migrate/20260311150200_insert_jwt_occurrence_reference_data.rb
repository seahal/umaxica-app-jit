# frozen_string_literal: true

class InsertJwtOccurrenceReferenceData < ActiveRecord::Migration[8.2]
  STATUS_DATA = {
    1 => "nothing",
    2 => "active",
    3 => "inactive",
    4 => "deleted",
  }.freeze

  CONTEXTS = {
    "AUTH_USER" => "User auth JWT",
    "AUTH_STAFF" => "Staff auth JWT",
    "APP_PREFERENCE" => "App preference JWT",
    "COM_PREFERENCE" => "Com preference JWT",
    "ORG_PREFERENCE" => "Org preference JWT",
  }.freeze

  COMMON_REASONS = {
    "MALFORMED_TOKEN" => "token is malformed",
    "UNKNOWN_KID" => "kid is unknown",
    "MISSING_KID" => "kid claim is missing",
    "ALG_NONE" => "alg none was supplied",
    "ALG_MISMATCH" => "algorithm does not match expected value",
    "MISSING_TYP" => "typ claim is missing",
    "TYP_MISMATCH" => "typ does not match expected value",
    "MISSING_ISS" => "issuer claim is missing",
    "ISS_MISMATCH" => "issuer does not match expected value",
    "MISSING_AUD" => "audience claim is missing",
    "AUD_MISMATCH" => "audience does not match expected value",
    "MISSING_EXP" => "expiration claim is missing",
    "EXPIRED" => "token is expired",
    "MISSING_NBF" => "not before claim is missing",
    "IMMATURE" => "token is not valid yet",
    "IAT_INVALID" => "issued at claim is invalid",
    "MISSING_JTI" => "jti claim is missing",
    "SIGNATURE_INVALID" => "signature verification failed",
    "DECODE_ERROR" => "decode failed before classification",
    "OTHER" => "uncategorized jwt anomaly",
  }.freeze

  AUTH_REASONS = {
    "MISSING_SUB" => "subject claim is missing",
    "MISSING_SID" => "session id claim is missing",
    "MISSING_ACT" => "actor claim is missing",
    "ACT_MISMATCH" => "actor does not match expected value",
  }.freeze

  PREFERENCE_REASONS = {
    "MISSING_PUBLIC_ID" => "preference public id claim is missing",
    "MISSING_PREFERENCE_TYPE" => "preference type claim is missing",
    "PREFERENCE_TYPE_MISMATCH" => "preference type does not match expected value",
    "HOST_MISMATCH" => "request host does not match expected host",
  }.freeze

  def up
    return unless table_exists?(:jwt_occurrence_statuses) && table_exists?(:jwt_occurrences)

    safety_assured do
      STATUS_DATA.each do |id, name|
        execute <<~SQL.squish
          INSERT INTO jwt_occurrence_statuses (id, name)
          VALUES (#{id}, #{connection.quote(name)})
          ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name
        SQL
      end

      catalog_rows.each_with_index do |(body, memo), index|
        public_id = format("jwt_occurrence_%06d", index + 1)
        execute <<~SQL.squish
          INSERT INTO jwt_occurrences (body, memo, public_id, status_id, expires_at, created_at, updated_at)
          VALUES (
            #{connection.quote(body)},
            #{connection.quote(memo)},
            #{connection.quote(public_id)},
            2,
            CURRENT_TIMESTAMP + INTERVAL '7 years',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
          )
          ON CONFLICT (body) DO UPDATE SET
            memo = EXCLUDED.memo,
            status_id = EXCLUDED.status_id,
            updated_at = EXCLUDED.updated_at
        SQL
      end
    end

    ensure_status_sequence!
    ensure_occurrence_sequence!
  end

  def down
    return unless table_exists?(:jwt_occurrences) && table_exists?(:jwt_occurrence_statuses)

    safety_assured do
      execute "DELETE FROM jwt_occurrences"
      execute "DELETE FROM jwt_occurrence_statuses WHERE id IN (1, 2, 3, 4)"
    end
  end

  private

  def catalog_rows
    CONTEXTS.flat_map do |context_code, context_name|
      reasons = COMMON_REASONS.merge(context_code.start_with?("AUTH_") ? AUTH_REASONS : PREFERENCE_REASONS)
      reasons.map do |reason_code, reason_description|
        body = "#{context_code}_#{reason_code}"
        memo = "#{context_name} anomaly: #{reason_description}."
        [body, memo]
      end
    end
  end

  def ensure_status_sequence!
    ensure_sequence!(:jwt_occurrence_statuses, STATUS_DATA.keys.max)
  end

  def ensure_occurrence_sequence!
    max_id = select_value("SELECT COALESCE(MAX(id), 0) FROM jwt_occurrences").to_i
    ensure_sequence!(:jwt_occurrences, max_id)
  end

  def ensure_sequence!(table_name, max_id)
    sequence_name = select_value("SELECT pg_get_serial_sequence(#{connection.quote(table_name.to_s)}, 'id')")
    return if sequence_name.blank? || max_id <= 0

    safety_assured do
      execute "SELECT setval(#{connection.quote(sequence_name)}, #{Integer(max_id)}, true)"
    end
  end
end
