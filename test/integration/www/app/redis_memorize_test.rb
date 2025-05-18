# # frozen_string_literal: true
#
# require "test_helper"
#
# class Www::App::RedisMemorizeTest < ActiveSupport::TestCase
#   setup do
#     # Initialize test dependencies
#     @redis = Redis.new(host: File.exist?("/.dockerenv") ? ENV["REDIS_SESSION_URL"] : "localhost", port: 6379, db: 0)
#     @prefix = "test_prefix"
#     @postfix = "test_postfix"
#     Www::App::ContactsController.new # Initialize the controller to ensure the RedisMemorize instance is created
#     @memorize = Www::App::RedisMemorize.new(prefix: @prefix, postfix: @postfix)
#     @test_key = "test_key"
#     @test_value = "secret_value_123"
#     @expected_redis_key = "#{Rails.env}.#{@prefix}.#{@postfix}.#{@test_key}"
#
#     # Clean up Redis before tests
#     @redis.del(@expected_redis_key)
#   end
#
#   teardown do
#     # Clean up Redis before tests
#     @redis.del(@expected_redis_key)
#   end
#
#   test "correctly decrypts encrypted values" do
#     # Set a value to the key
#     @memorize["one"] = @test_value
#     retrieved_value = @memorize["one"]
#     assert_equal @test_value, retrieved_value
#   end
#
#   test "returns nil for non-existent keys" do
#     assert_nil @memorize["non_existent_key"]
#   end
# end
