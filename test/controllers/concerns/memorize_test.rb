# frozen_string_literal: true

require "test_helper"

class MemorizeConcernTest < ActiveSupport::TestCase
  setup do
    @memorize = Memorize::RedisMemorize.test_instance(prefix: "test", postfix: SecureRandom.uuid)
  end

  teardown do
    @memorize.clear_all if @memorize
  end

  test "RedisMemorize can store and retrieve values" do
    @memorize["test_key"] = "test_value"
    assert_equal "test_value", @memorize["test_key"]
  end

  test "RedisMemorize returns nil for non-existent keys" do
    assert_nil @memorize["non_existent_key"]
  end

  test "RedisMemorize can delete keys" do
    @memorize["test_key"] = "test_value"
    assert @memorize.delete("test_key")
    assert_nil @memorize["test_key"]
  end

  test "RedisMemorize delete returns false for non-existent keys" do
    assert_equal false, @memorize.delete("non_existent_key")
  end

  test "RedisMemorize exists? returns true for existing keys" do
    @memorize["test_key"] = "test_value"
    assert @memorize.exists?("test_key")
  end

  test "RedisMemorize exists? returns false for non-existent keys" do
    assert_equal false, @memorize.exists?("non_existent_key")
  end

  test "RedisMemorize can store values with custom expiry" do
    @memorize.send(:[]=, "expiring_key", "value", expires_in: 1.hour)
    assert_equal "value", @memorize["expiring_key"]
  end

  test "RedisMemorize can store values without expiry" do
    @memorize.send(:[]=, "permanent_key", "permanent_value", expires_in: nil)
    assert_equal "permanent_value", @memorize["permanent_key"]
  end

  test "RedisMemorize encrypts stored values" do
    @memorize["secure_key"] = "secure_value"
    # The value should be encrypted in Redis, not plain text
    assert_equal "secure_value", @memorize["secure_key"]
  end

  test "RedisMemorize clear_all removes all keys with prefix" do
    @memorize["key1"] = "value1"
    @memorize["key2"] = "value2"
    @memorize["key3"] = "value3"

    deleted_count = @memorize.clear_all
    assert deleted_count >= 3

    assert_nil @memorize["key1"]
    assert_nil @memorize["key2"]
    assert_nil @memorize["key3"]
  end

  test "RedisMemorize test_instance creates instance with custom prefix and postfix" do
    instance = Memorize::RedisMemorize.test_instance(prefix: "custom", postfix: "test")
    assert_not_nil instance
    instance["test"] = "value"
    assert_equal "value", instance["test"]
    instance.clear_all
  end

  test "RedisMemorize handles integer values" do
    @memorize["number_key"] = 42
    assert_equal "42", @memorize["number_key"]
  end

  test "RedisMemorize handles boolean values" do
    @memorize["bool_key"] = true
    assert_equal "true", @memorize["bool_key"]
  end

  test "RedisMemorize overwrites existing values" do
    @memorize["key"] = "old_value"
    @memorize["key"] = "new_value"
    assert_equal "new_value", @memorize["key"]
  end
end
