# frozen_string_literal: true

require "test_helper"

class SolidCacheTest < ActiveSupport::TestCase
  setup do
    # Clear any existing cache entries
    SolidCache::Entry.delete_all

    # Create a properly configured solid_cache store instance
    @cache = SolidCache::Store.new
  end

  test "cache database connection is configured correctly" do
    # Verify the cache database connection
    assert_equal "cache", SolidCache::Entry.connection_db_config.name
    assert_equal "test_cache_db", SolidCache::Entry.connection_db_config.configuration_hash[:database]
  end

  test "can create cache entry directly" do
    initial_count = SolidCache::Entry.count

    @cache.write("test_key", "test_value")

    # Read it back to verify it was written
    assert_equal "test_value", @cache.read("test_key")

    # Verify at least one entry exists in database
    assert_operator SolidCache::Entry.count, :>=, initial_count
  end

  test "can read from cache" do
    @cache.write("read_test_key", "read_test_value")

    value = @cache.read("read_test_key")

    assert_equal "read_test_value", value
  end

  test "can delete from cache" do
    @cache.write("delete_test_key", "delete_test_value")

    # Verify it exists first
    assert_equal "delete_test_value", @cache.read("delete_test_key")

    # Delete it
    @cache.delete("delete_test_key")

    # Verify it's gone
    assert_nil @cache.read("delete_test_key")
  end

  test "can fetch with block" do
    call_count = 0

    # First fetch should execute the block
    value1 = @cache.fetch("fetch_test_key") do
      call_count += 1
      "computed_value"
    end

    # Second fetch should use cached value
    value2 = @cache.fetch("fetch_test_key") do
      call_count += 1
      "should_not_be_called"
    end

    assert_equal "computed_value", value1
    assert_equal "computed_value", value2
    assert_equal 1, call_count
  end

  test "can store complex objects" do
    complex_object = {
      string: "hello",
      number: 42,
      array: [ 1, 2, 3 ],
      nested: { key: "value" }
    }

    @cache.write("complex_key", complex_object)
    retrieved = @cache.read("complex_key")

    assert_equal complex_object, retrieved
  end

  test "can clear all entries" do
    @cache.write("key1", "value1")
    @cache.write("key2", "value2")

    # Verify keys exist
    assert_equal "value1", @cache.read("key1")

    @cache.clear

    # Verify keys are gone after clear
    assert_nil @cache.read("key1")
    assert_nil @cache.read("key2")
  end

  test "can check if key exists" do
    @cache.write("exist_test_key", "exist_test_value")

    assert @cache.exist?("exist_test_key")
    assert_not @cache.exist?("non_existent_key")
  end

  test "stores byte size correctly" do
    test_value = "a" * 1000
    @cache.write("size_test_key", test_value)

    entry = SolidCache::Entry.order(created_at: :desc).first

    assert_not_nil entry
    assert_operator entry.byte_size, :>, 0
  end

  test "can increment counter" do
    @cache.write("counter_key", 0, raw: true)

    @cache.increment("counter_key")

    assert_equal 1, @cache.read("counter_key", raw: true).to_i

    @cache.increment("counter_key", 5)

    assert_equal 6, @cache.read("counter_key", raw: true).to_i
  end

  test "can decrement counter" do
    @cache.write("decrement_key", 10, raw: true)

    @cache.decrement("decrement_key")

    assert_equal 9, @cache.read("decrement_key", raw: true).to_i

    @cache.decrement("decrement_key", 3)

    assert_equal 6, @cache.read("decrement_key", raw: true).to_i
  end

  test "fetch_multi returns multiple values" do
    @cache.write("multi_key1", "value1")
    @cache.write("multi_key2", "value2")
    @cache.write("multi_key3", "value3")

    results = @cache.fetch_multi("multi_key1", "multi_key2", "multi_key3") do |key|
      "default_#{key}"
    end

    assert_equal "value1", results["multi_key1"]
    assert_equal "value2", results["multi_key2"]
    assert_equal "value3", results["multi_key3"]
  end

  test "can query cache statistics" do
    @cache.write("stat_key1", "value1")
    @cache.write("stat_key2", "a" * 1000)
    @cache.write("stat_key3", "value3")

    assert_operator SolidCache::Entry.count, :>=, 3

    total_size = SolidCache::Entry.sum(:byte_size)

    assert_operator total_size, :>, 0
  end

  test "handles cache key normalization" do
    # Test that different key formats are handled correctly
    @cache.write("simple_key", "value1")
    @cache.write("key:with:colons", "value2")
    @cache.write("key/with/slashes", "value3")

    assert_equal "value1", @cache.read("simple_key")
    assert_equal "value2", @cache.read("key:with:colons")
    assert_equal "value3", @cache.read("key/with/slashes")
  end
end
