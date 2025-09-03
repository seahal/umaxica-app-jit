# frozen_string_literal: true

# INFO: This file was created for checking memorize helper

require "test_helper"

class RedisMemorizeTest < ActiveSupport::TestCase
  setup do
    @memorize = Memorize::RedisMemorize.test_instance(prefix: "test_prefix", postfix: "test_postfix")
    @test_key = "test_key"
    @test_value = "secret_value_123"

    # Clean up Redis before tests
    @memorize.clear_all
  end

  teardown do
    # Clean up Redis after tests
    @memorize.clear_all
  end

  # test "returns nil for non-existent keys" do
  #   assert_nil @memorize["non_existent_key"]
  # end

  # test "different instances have isolated data" do
  #   other_memorize = Memorize::RedisMemorize.test_instance(prefix: "other", postfix: "instance")
  #
  #   @memorize[@test_key] = @test_value
  #   other_memorize[@test_key] = "different_value"
  #
  #   assert_equal @test_value, @memorize[@test_key]
  #   assert_equal "different_value", other_memorize[@test_key]
  #
  #   # Clean up
  #   other_memorize.clear_all
  # end
end
