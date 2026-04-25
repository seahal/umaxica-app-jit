# typed: false
# frozen_string_literal: true

module Sign
  module Preference
    module EmailToken
      PURPOSE = "sign-preference-email"
      TTL = 2.hours
      ENCRYPTOR_CACHE = Concurrent::Map.new

      module_function

      def issue(email_record_id:, email_record_type:, audience:)
        encryptor.encrypt_and_sign(
          {
            "id" => email_record_id.to_s,
            "type" => email_record_type.to_s,
            "aud" => audience.to_s,
          },
          purpose: PURPOSE,
          expires_in: TTL,
        )
      end

      def parse(token, audience:)
        return nil if token.blank?

        payload = encryptor.decrypt_and_verify(token, purpose: PURPOSE)
        return nil unless payload
        return nil if payload["aud"] != audience.to_s

        id = payload["id"].to_s
        type = payload["type"].to_s
        return nil if id.blank? || type.blank?

        { email_record_id: id.to_i, email_record_type: type }
      rescue ActiveSupport::MessageEncryptor::InvalidMessage,
             ActiveSupport::MessageVerifier::InvalidSignature
        nil
      end

      def encryptor
        ENCRYPTOR_CACHE.compute_if_absent(PURPOSE) do
          secret = Rails.application.secret_key_base
          key_len = ActiveSupport::MessageEncryptor.key_len
          key = ActiveSupport::KeyGenerator.new(secret).generate_key(PURPOSE, key_len)
          ActiveSupport::MessageEncryptor.new(key, cipher: "aes-256-gcm")
        end
      end
    end
  end
end
