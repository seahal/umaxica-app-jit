# frozen_string_literal: true

module Www
  module App
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern

      before_action :check_authentication

      protected

      def logged_in_user?
        false
      end


      private

      def check_authentication
        anonymous_id = 0
        user_id = 0
        staff_id = 0
        customer_id = 0
        last_mfa_time = nil
        refresh_token_expires_at = 1.years.from_now

        cookies.encrypted[:access_token] = {
          value: { id: nil, user_id:, staff_id:, created_at: Time.now, expires_at: nil },
          httponly: true,
          secure: Rails.env.production? ? true : false,
          expires: 30.seconds.from_now
        }
        cookies.encrypted[:refresh_token] = {
          value: { id: nil, user_id:, staff_id:, last_mfa_time:, created_at: Time.now, expires_at: refresh_token_expires_at },
          httponly: true,
          secure: Rails.env.production? ? true : false,
          expires: refresh_token_expires_at
        }
        cookies.signed[:identity_token] = {
          value: { account_ids: [], common_account_id: nil },
          httponly: false,
          secure: Rails.env.production? ? true : false,
          expires: refresh_token_expires_at
        }
      end

      # following method made for set value in Redis.
      def memorize
        @memorize ||= RedisMemorize.new(originality_prefix: request.host, originality_postfix: session.id)
      end

      helper_method :memorize
    end
    class RedisMemorize
      def initialize(originality_prefix: nil, originality_postfix: nil)
        @originality_prefix = originality_prefix.to_s
        @originality_postfix = originality_postfix.to_s
        redis_config = RedisClient.config(host: File.exist?("/.dockerenv") ? ENV["REDIS_SESSION_URL"] : "localhost", port: 6379, db: 0)
        @redis = redis_config.new_pool(timeout: 0.5, size: Integer(ENV.fetch("RAILS_MAX_THREADS", 5)))

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
end
