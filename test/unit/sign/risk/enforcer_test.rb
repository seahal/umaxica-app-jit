# frozen_string_literal: true

require "test_helper"

module Sign
  module Risk
    class EnforcerTest < ActiveSupport::TestCase
      fixtures :users, :user_statuses, :user_token_statuses, :user_token_kinds

      setup do
        @user = users(:one) # Assuming fixtures or factory
        @user_id = @user.id

        # Enable feature flag for tests
        @original_env = ENV["RISK_ENFORCEMENT_ENABLED"]
        ENV["RISK_ENFORCEMENT_ENABLED"] = "true"
      end

      teardown do
        ENV["RISK_ENFORCEMENT_ENABLED"] = @original_env
      end

      test "does nothing if feature flag is off" do
        ENV["RISK_ENFORCEMENT_ENABLED"] = "false"

        Engine.stub :score, 100 do
          Enforcer.stub :revoke!, ->(_) { raise "Should not be called" } do
            result = Enforcer.call(@user)
            assert_nil result
          end
        end
      end

      test "revokes if score is 100" do
        Engine.stub :score, 100 do
          # Enforcer.revoke! should be called
          called = false
          Enforcer.stub :revoke!, ->(u) { called = true; assert_equal @user, u } do
            Enforcer.call(@user)
          end
          assert called, "revoke! should have been called"
        end
      end

      test "requires step up if score is 60" do
        Engine.stub :score, 60 do
          called = false
          Enforcer.stub :require_step_up!, ->(u) { called = true; assert_equal @user, u } do
            Enforcer.call(@user)
          end
          assert called, "require_step_up! should have been called"
        end
      end

      test "does nothing if score is 0" do
        Engine.stub :score, 0 do
          Enforcer.stub :revoke!, ->(_) { raise "Should not be called" } do
            Enforcer.stub :require_step_up!, ->(_) { raise "Should not be called" } do
              result = Enforcer.call(@user)
              assert_nil result
            end
          end
        end
      end

      # Mock Redis for flow test
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

          min_val = min.to_f
          @data[key].select { |item| item[:score] >= min_val }.pluck(:member)
        end

        def expire(key, ttl)
        end

        def set(key, val, ex:)
        end
      end

      test "end-to-end risk flow" do
        # Setup Mock Redis for this test only
        mock_redis = MockRedis.new
        silence_warnings { ::REDIS_CLIENT = mock_redis }

        @user.user_tokens.destroy_all # Ensure we don't hit session limit

        # Create token with valid public_id and expiry
        token = UserToken.create!(
          user: @user,
          refresh_expires_at: 1.day.from_now,
          public_id: "test_#{SecureRandom.hex(4)}",
          # Default status/kind should trigger if FKs exist.
          # If FK check fails, we might need to assume fixtures loaded statuses.
        )

        # 1. Emit Risk Event (writes to Redis)
        Sign::Risk::Emitter.emit("refresh_reuse_detected", user_id: @user.id)

        # 2. Call Enforcer (reads from Redis via Engine, then Revokes)
        # Note: We are NOT stubbing Engine.score here! We want real Engine logic using our MockRedis.
        Sign::Risk::Enforcer.call(@user)

        # 3. Check revocation
        token.reload
        assert_not_nil token.revoked_at
      end
    end
  end
end
