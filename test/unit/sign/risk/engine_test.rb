# frozen_string_literal: true

require "test_helper"

module Sign
  module Risk
    class EngineTest < ActiveSupport::TestCase
      # Mock Redis client for testing
      class MockRedis
        def initialize
          @data = {}
        end

        def zadd(key, score, member)
          @data[key] ||= []
          @data[key] << { score: score, member: member }
        end

        def zrangebyscore(key, min, _max)
          return [] unless @data[key]

          # Simplified range logic for test
          # Assuming max is "+inf" and min is a float
          min_val = min.to_f

          @data[key]
            .select { |item| item[:score] >= min_val }
            .pluck(:member)
        end

        def expire(key, ttl)
          # no-op
        end

        def set(key, val, ex:)
          # no-op
        end

        def clear!
          @data = {}
        end
      end

      setup do
        @user_id = SecureRandom.uuid
        @mock_redis = MockRedis.new
        # Stub REDIS_CLIENT constant.
        # Since we can't easily reassign constants in Ruby without warning/error,
        # we'll assume the implementation uses REDIS_CLIENT if defined.
        # Check if REDIS_CLIENT is defined in test env.
        # If not, we might need to define it or stub the Emitter/Engine internals.
        # But wait, Engine uses REDIS_CLIENT directly.
        # We can stub the method that calls Redis or stub the constant.

        # In this environment, let's assume we can stub `Sign::Risk::Engine` internals OR `REDIS_CLIENT`.
        # However, `REDIS_CLIENT` is top-level.

        # Better approach: If REDIS_CLIENT assumes real redis, we should use a mock.
        # Or, we can redefine REDIS_CLIENT with silence_warnings.
      end

      test "refresh_reuse_detected returns 100" do
        # We need to inject events into the Engine's view.
        # Since Engine reads from Redis, we should populate Redis (or our mock).

        # Ideally, we stub `Sign::Risk::Engine#score` to use our mock,
        # BUT the code uses `cat` `REDIS_CLIENT`.

        # Let's try to trust that we can simply create events and persist them if REDIS_CLIENT is available.
        # If REDIS_CLIENT isn't available in test env, our code returns 0.
        # The prompt implies we should implement it.

        # Let's see if we can use Minitest::Mock on REDIS_CLIENT if it exists?
        # Or define it if missing.

        mock_redis = @mock_redis

        silence_warnings do
          ::REDIS_CLIENT = mock_redis
        end

        # Emit an event manually
        event = Event.new("refresh_reuse_detected", payload: { user_id: @user_id })
        Emitter.persist(event) # This writes to our mock_redis

        assert_equal 100, Engine.score(@user_id)
      end

      test "auth_failed 5 times returns 60" do
        mock_redis = @mock_redis
        silence_warnings do
          ::REDIS_CLIENT = mock_redis
        end

        5.times do
          event = Event.new("auth_failed", payload: { user_id: @user_id })
          Emitter.persist(event)
        end

        assert_equal 60, Engine.score(@user_id)
      end

      test "refresh_failed 5 times returns 40" do
        mock_redis = @mock_redis
        silence_warnings do
          ::REDIS_CLIENT = mock_redis
        end

        5.times do
          event = Event.new("refresh_failed", payload: { user_id: @user_id })
          Emitter.persist(event)
        end

        assert_equal 40, Engine.score(@user_id)
      end

      test "mixed events return max score" do
        mock_redis = @mock_redis
        silence_warnings do
          ::REDIS_CLIENT = mock_redis
        end

        # 100 takes precedence
        Emitter.persist(Event.new("refresh_reuse_detected", payload: { user_id: @user_id }))
        5.times { Emitter.persist(Event.new("auth_failed", payload: { user_id: @user_id })) }

        assert_equal 100, Engine.score(@user_id)
      end

      test "returns 0 for safe events" do
        mock_redis = @mock_redis
        silence_warnings do
          ::REDIS_CLIENT = mock_redis
        end

        Emitter.persist(Event.new("session_issued", payload: { user_id: @user_id }))
        assert_equal 0, Engine.score(@user_id)
      end
    end
  end
end
