# typed: false
# frozen_string_literal: true

require "test_helper"

class TelephoneRegistrableTest < ActiveSupport::TestCase
  class MockRequest
    attr_accessor :remote_ip

    def initialize(ip = "192.168.1.1")
      @remote_ip = ip
    end
  end

  class TestController
    include Sign::TelephoneRegistrable

    attr_accessor :request

    def initialize(ip = "192.168.1.1")
      @request = MockRequest.new(ip)
    end
  end

  setup do
    @controller = TestController.new
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @original_cache
  end

  # ---------------------------------------------------------------------------
  # check_telephone_verification_rate_limit!
  # ---------------------------------------------------------------------------

  test "check_telephone_verification_rate_limit! allows requests within limit" do
    remaining = nil
    5.times do
      remaining = @controller.send(:check_telephone_verification_rate_limit!)
    end
    assert_equal 0, remaining
  end

  test "check_telephone_verification_rate_limit! raises error when limit exceeded" do
    5.times { @controller.send(:check_telephone_verification_rate_limit!) }

    error =
      assert_raises(RateLimiter::RateLimitExceeded) do
        @controller.send(:check_telephone_verification_rate_limit!)
      end

    assert_not_nil error.retry_after
  end

  test "rate limit is per IP address" do
    5.times { @controller.send(:check_telephone_verification_rate_limit!) }

    assert_raises(RateLimiter::RateLimitExceeded) do
      @controller.send(:check_telephone_verification_rate_limit!)
    end

    other_controller = TestController.new("10.0.0.1")
    assert_nothing_raised { other_controller.send(:check_telephone_verification_rate_limit!) }
  end

  # ---------------------------------------------------------------------------
  # initiate_telephone_verification
  # ---------------------------------------------------------------------------

  test "initiate_telephone_verification returns false when user is blank" do
    result = @controller.initiate_telephone_verification(nil, "+819012345678")
    assert_not result
  end

  test "initiate_telephone_verification returns false when user is empty string" do
    result = @controller.initiate_telephone_verification("", "+819012345678")
    assert_not result
  end

  # ---------------------------------------------------------------------------
  # complete_telephone_verification
  # ---------------------------------------------------------------------------

  test "complete_telephone_verification returns :session_expired when record not found" do
    result = @controller.complete_telephone_verification("nonexistent-id", "123456")
    assert_equal :session_expired, result
  end
end
