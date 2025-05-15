# frozen_string_literal: true

require "test_helper"

class Www::App::RedisMemorizeTest < ActiveSupport::TestCase
  setup do
    # Initialize test dependencies
    @redis = Redis.new(host: File.exist?("/.dockerenv") ? ENV["REDIS_SESSION_URL"] : "localhost", port: 6379, db: 0)
    @prefix = "test_prefix"
    @postfix = "test_postfix"
    Www::App::ContactsController.new # Initialize the controller to ensure the RedisMemorize instance is created
    @memorize = Www::App::RedisMemorize.new(originality_prefix: @prefix, originality_postfix: @postfix)
    @test_key = "test_key"
    @test_value = "secret_value_123"
    @expected_redis_key = "#{Rails.env}.#{@prefix}.#{@postfix}.#{@test_key}"

    # Clean up Redis before tests
    @redis.del(@expected_redis_key)
  end

  test "stores encrypted values in Redis" do
    # Set a value to the key
    @memorize[@test_key] = @test_value

    # Retrieve the raw value directly from Redis
    raw_value = @redis.get(@expected_redis_key)

    # Verify that a value exists
    assert_not_nil raw_value

    # Verify that the stored value is encrypted (not plaintext)
    assert_not_equal @test_value, raw_value

    # Check that the encrypted value matches ActiveSupport::MessageEncryptor format
    assert_includes raw_value, "--"

    # Ensure the encrypted value is Base64 encoded as expected
    assert_nothing_raised do
      Base64.strict_decode64(raw_value.split("--").first)
    end
  end

  test "correctly decrypts encrypted values" do
    # Set a value to the key
    @memorize[@test_key] = @test_value

    # Retrieve and verify the decrypted value matches original
    retrieved_value = @memorize[@test_key]
    assert_equal @test_value, retrieved_value
  end

  test "returns nil for non-existent keys" do
    # Verify nil is returned for keys that don't exist
    assert_nil @memorize["non_existent_key"]
  end

  # test "can encrypt/decrypt with different instances using the same keys" do
  #   # Set a value with the first instance
  #   @memorize[@test_key] = @test_value
  #
  #   # Create a second instance with the same configuration
  #   another_memorize = Www::App::RedisMemorize.new(originality_prefix: @prefix, originality_postfix: @postfix)
  #
  #   # Verify the second instance can decrypt the value
  #   retrieved_value = another_memorize[@test_key]
  #   assert_equal @test_value, retrieved_value
  # end
#
#   test "cannot decrypt tampered values" do
#     # Set a value to the key
#     @memorize[@test_key] = @test_value
#
#     # Retrieve the raw value and tamper with it
#     raw_value = @redis.get(@expected_redis_key)
#     tampered_value = raw_value.reverse
#     @redis.set(@expected_redis_key, tampered_value)
#
#     # Verify that the tampered value cannot be decrypted (returns nil)
#     assert_nil @memorize[@test_key]
end
