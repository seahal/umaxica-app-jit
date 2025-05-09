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
        user_id = 0
        staff_id = 0
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
        @memorize ||= RedisMemorize.new(originality_prefix: request.host)
      end

      helper_method :memorize
    end

    # Code for Redis Memorization Class
    class RedisMemorize
      def initialize(originality_prefix: nil)
        @originality_prefix = originality_prefix
        redis_config = RedisClient.config(host: File.exist?("/.dockerenv") ? ENV["REDIS_SESSION_URL"] : "localhost", port: 6379, db: 0)
        @redis = redis_config.new_pool(timeout: 0.5, size: Integer(ENV.fetch("RAILS_MAX_THREADS", 5)))
      end

      def [](key)
        @redis.call("GET", "#{@originality_prefix}.#{key}")
      end

      def []=(key, value, expires_in = 2.hours)
        @redis.call("SET", "#{@originality_prefix}.#{key}", value.to_s, "EX", expires_in.to_i)
      end
    end
  end
end
