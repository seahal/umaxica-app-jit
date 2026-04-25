# typed: false
# frozen_string_literal: true

require "test_helper"

module Jit
  module Identity
    module Sign
      module In
        class OtpResendPolicyTest < ActiveSupport::TestCase
          include ActiveSupport::Testing::TimeHelpers

          test "base cooldown is 30 seconds when one issue exists in 5 minutes" do
            policy = Jit::Identity::Sign::In::OtpResendPolicy.new(base_seconds: 30, cap_seconds: 15.minutes.to_i)

            travel_to Time.zone.parse("2026-02-12 10:00:00") do
              issued = [29.seconds.ago]
              result = policy.evaluate(issued_timestamps: issued)

              assert_not result.resendable
              assert_equal 1, result.n5m
              assert_equal 30, result.cooldown
              assert_equal 1, result.retry_after
            end
          end

          test "cooldown grows exponentially with n5m" do
            policy = Jit::Identity::Sign::In::OtpResendPolicy.new(base_seconds: 30, cap_seconds: 15.minutes.to_i)

            travel_to Time.zone.parse("2026-02-12 10:00:00") do
              issued = [4.minutes.ago, 2.minutes.ago, 20.seconds.ago]
              result = policy.evaluate(issued_timestamps: issued)

              assert_not result.resendable
              assert_equal 3, result.n5m
              assert_equal 120, result.cooldown
              assert_equal 100, result.retry_after
            end
          end

          test "cooldown is capped by policy cap" do
            policy = Jit::Identity::Sign::In::OtpResendPolicy.new(base_seconds: 30, cap_seconds: 60)

            travel_to Time.zone.parse("2026-02-12 10:00:00") do
              issued = [4.minutes.ago, 3.minutes.ago, 2.minutes.ago, 1.minute.ago, 20.seconds.ago]
              result = policy.evaluate(issued_timestamps: issued)

              assert_not result.resendable
              assert_equal 60, result.cooldown
              assert_equal 40, result.retry_after
            end
          end

          test "resendable when no issued in last 5 minutes" do
            policy = Jit::Identity::Sign::In::OtpResendPolicy.new(base_seconds: 30, cap_seconds: 15.minutes.to_i)

            travel_to Time.zone.parse("2026-02-12 10:00:00") do
              issued = [6.minutes.ago]
              result = policy.evaluate(issued_timestamps: issued)

              assert result.resendable
              assert_equal 0, result.retry_after
              assert_equal 0, result.n5m
            end
          end
        end
      end
    end
  end
end
