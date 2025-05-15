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

  teardown do
    # Clean up Redis after tests
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

  test "cannot decrypt tampered values" do
    # Set a value to the key
    @memorize[@test_key] = @test_value

    # Retrieve the raw value and tamper with it
    raw_value = @redis.get(@expected_redis_key)
    tampered_value = raw_value.reverse
    @redis.set(@expected_redis_key, tampered_value)

    # Verify that the tampered value cannot be decrypted (returns nil)
    assert_nil @memorize[@test_key]
  end
end

# Controller integration tests
class Www::App::RedisMemorizeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @redis = Redis.new(host: "localhost", port: 6379, db: 0)

    # Add a test route for the controller test
    Rails.application.routes.draw do
      get "test_memorize" => "test_memorize#index"
    end

    # Define a test controller that uses RedisMemorize
    class TestMemorizeController < Www::App::ApplicationController
      def index
        memorize["controller_test"] = "controller_value"
        render plain: memorize["controller_test"]
      end
    end
  end

  teardown do
    # Restore original routes
    Rails.application.reload_routes!

    # Clean up test controller
    Object.send(:remove_const, :TestMemorizeController) if defined?(TestMemorizeController)
  end

  # test "can use RedisMemorize from controllers" do
  #   get '/test_memorize'
  #   assert_response :success
  #   assert_equal 'controller_value', response.body
  #
  #   # Verify a session was established
  #   assert session.id, "Session ID should exist"
  #
  #   # Retrieve the raw value directly from Redis
  #   redis_key = "#{Rails.env}.#{request.host}.#{session.id}.controller_test"
  #   raw_value = @redis.get(redis_key)
  #
  #   # Verify the value exists and is encrypted
  #   assert raw_value, "Value should be stored in Redis"
  #   assert_not_equal 'controller_value', raw_value, "Value should be encrypted"
  # end
end
