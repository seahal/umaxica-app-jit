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
    def initialize(prefix: nil, postfix: nil, redis_config: nil, encryptor: nil)
      @originality_prefix = prefix.to_s
      @originality_postfix = postfix.to_s
      @redis = redis_config&.new_pool(timeout: 1,
                                      size: Integer(ENV.fetch(
                                        "RAILS_MAX_THREADS", 5
                                      ))) || default_redis_pool
      @encryptor = encryptor || default_encryptor
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

    def []=(key, value, expires_in: 2.hours)
      encrypted_value = @encryptor.encrypt_and_sign(value.to_s)
      if expires_in
        @redis.call("SET", redis_key(key), encrypted_value, "EX", expires_in.to_i)
      else
        @redis.call("SET", redis_key(key), encrypted_value)
      end
    end

    def delete(key)
      result = @redis.call("DEL", redis_key(key))
      result > 0
    end

    def exists?(key)
      @redis.call("EXISTS", redis_key(key)) > 0
    end

    def clear_all
      pattern = redis_key("*")
      deleted_count = 0

      # Use SCAN instead of KEYS for better performance and atomic operations
      cursor = "0"
      loop do
        result = @redis.call("SCAN", cursor, "MATCH", pattern, "COUNT", 100)
        cursor, keys = result

        unless keys.empty?
          # Delete keys in smaller batches to avoid race conditions
          deleted_count += @redis.call("DEL", *keys)
        end

        break if cursor == "0"
      end

      deleted_count
    end

    # For testing - create a new instance with custom prefix/postfix
    def self.test_instance(prefix: "test", postfix: "instance")
      new(prefix: prefix, postfix: postfix)
    end

    private

    def redis_key(key)
      "#{Rails.env}.#{@originality_prefix}.#{@originality_postfix}.#{key}"
    end

    def default_redis_pool
      redis_config = RedisClient.config(
        driver: :hiredis,
        host: File.exist?("/.dockerenv") ? ENV["REDIS_SESSION_URL"] : "localhost",
        port: 6379,
        db: 2
      )
      redis_config.new_pool(timeout: 1, size: Integer(ENV.fetch("RAILS_MAX_THREADS", 5)))
    end

    def default_encryptor
      # ActiveSupport::MessageEncryptorのインスタンスを作成
      secret_key_base = Rails.application.credentials.secret_key_base || ENV.fetch("SECRET_KEY_BASE", "development_key")
      key_generator = ActiveSupport::KeyGenerator.new(secret_key_base)
      key_len = ActiveSupport::MessageEncryptor.key_len
      secret = key_generator.generate_key("redis_memorize_encryption", key_len)
      ActiveSupport::MessageEncryptor.new(secret)
    end
  end
end
