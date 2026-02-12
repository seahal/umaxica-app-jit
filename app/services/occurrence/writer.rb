# frozen_string_literal: true

module Occurrence
  class Writer
    EMAIL_TTL = 366.days
    TELEPHONE_TTL = 366.days
    IP_TTL = 31.days
    MAX_MEMO_LENGTH = 1000
    STATUS_ID_CACHE = Concurrent::Map.new

    class MemoTooLongError < ApplicationError
      def initialize
        super("errors.occurrence.memo_too_long")
      end
    end

    class << self
      def log_email!(email:, status:, memo: "")
        body = Occurrence::Hmac.email_hmac(email)
        create_occurrence!(EmailOccurrence, EmailOccurrenceStatus, body, status, memo, EMAIL_TTL)
      end

      def log_telephone!(telephone:, status:, memo: "")
        body = Occurrence::Hmac.telephone_hmac(telephone)
        create_occurrence!(TelephoneOccurrence, TelephoneOccurrenceStatus, body, status, memo, TELEPHONE_TTL)
      end

      def log_ip!(ip:, status:, memo: "")
        body = Occurrence::Hmac.ip_hmac(ip)
        create_occurrence!(IpOccurrence, IpOccurrenceStatus, body, status, memo, IP_TTL)
      end

      private

      def create_occurrence!(model_class, status_class, body, status, memo, ttl)
        memo_value = memo.to_s
        raise MemoTooLongError if memo_value.length > MAX_MEMO_LENGTH

        model_class.create!(
          body: body,
          status_id: status_id_for(status_class, status),
          memo: memo_value,
          expires_at: Time.current + ttl,
        )
      end

      def status_id_for(status_class, status)
        key = status.to_s.upcase
        STATUS_ID_CACHE.compute_if_absent(status_class) { Concurrent::Map.new }
                       .compute_if_absent(key) do
          status_id = status_class.const_get(key)
          status_class.find_or_create_by!(id: status_id).id
        end
      end
    end
  end
end
