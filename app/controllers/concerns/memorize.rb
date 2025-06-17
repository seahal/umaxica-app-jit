# frozen_string_literal: true

module Memorize
  extend ActiveSupport::Concern

  included do
    helper_method :memorize
  end

  private

  # following method made for set value in Redis.
  def memorize
    @memorize ||= RedisMemorize.new(prefix: request.host, postfix: session.id)
  end

  class RedisMemorize
    def initialize(prefix: nil, postfix: nil)
      @originality_prefix = prefix.to_s
      @originality_postfix = postfix.to_s
      redis_config = RedisClient.config(host: File.exist?("/.dockerenv") ? ENV["REDIS_SESSION_URL"] : "localhost", port: 6379, db: 0)
      @redis = redis_config.new_pool(timeout: 1, size: Integer(ENV.fetch("RAILS_MAX_THREADS", 5)))

      # ActiveSupport::MessageEncryptorのインスタンスを作成
      secret_key_base = Rails.application.credentials.secret_key_base || ENV.fetch("SECRET_KEY_BASE", "development_key")
      key_generator = ActiveSupport::KeyGenerator.new(secret_key_base)
      key_len = ActiveSupport::MessageEncryptor.key_len
      secret = key_generator.generate_key("redis_memorize_encryption", key_len)
      @encryptor = ActiveSupport::MessageEncryptor.new(secret)
    end

    def [](key)
      encrypted_value = @redis.call("GET", redis_key(key))
      return nil unless encrypted_value

      begin
        @encryptor.decrypt_and_verify(encrypted_value)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
        Rails.logger.error "Failed to decrypt Redis value for key: #{key}"
        nil
      end
    end

    def []=(key, value, expires_in = 2.hours)
      encrypted_value = @encryptor.encrypt_and_sign(value.to_s)
      @redis.call("SET", redis_key(key), encrypted_value, "EX", expires_in.to_i)
    end

    private

    def redis_key(key)
      "#{Rails.env}.#{@originality_prefix}.#{@originality_postfix}.#{key}"
    end
  end
end
