# typed: false
# frozen_string_literal: true

require "test_helper"

class CacheAsideTest < ActiveSupport::TestCase
  class MockStore
    attr_reader :fetched_keys, :written_keys

    def initialize
      @data = {}
      @fetched_keys = []
      @written_keys = []
    end

    def fetch(key, expires_in:, race_condition_ttl: nil)
      @fetched_keys << { key: key, expires_in: expires_in, race_condition_ttl: race_condition_ttl }
      @data[key] ||= yield
    end

    def read(key)
      @data[key]
    end

    def write(key, value, expires_in: nil)
      @written_keys << { key: key, expires_in: expires_in }
      @data[key] = value
    end

    delegate :delete, to: :@data
  end

  test "fetch calls underlying store with namespaced key and passes TTL params" do
    mock_store = MockStore.new
    cache_aside = CacheAside.new(store: mock_store, namespace: "test")

    result = cache_aside.fetch("user:1", expires_in: 60) { "value" }

    assert_equal "value", result
    assert_equal 1, mock_store.fetched_keys.size
    assert_equal "test:user:1", mock_store.fetched_keys.first[:key]
    assert_equal 60, mock_store.fetched_keys.first[:expires_in]
    assert_equal 2.seconds, mock_store.fetched_keys.first[:race_condition_ttl]
  end

  test "read returns value from underlying store with namespaced key" do
    mock_store = MockStore.new
    cache_aside = CacheAside.new(store: mock_store, namespace: "test")

    mock_store.write("test:user:1", "stored_value")

    result = cache_aside.read("user:1")

    assert_equal "stored_value", result
  end

  test "write writes to underlying store with namespaced key" do
    mock_store = MockStore.new
    cache_aside = CacheAside.new(store: mock_store, namespace: "test")

    cache_aside.write("user:1", "new_value")

    assert_equal "new_value", mock_store.read("test:user:1")
  end

  test "write with expires_in passes to underlying store" do
    mock_store = MockStore.new
    cache_aside = CacheAside.new(store: mock_store, namespace: "test")

    cache_aside.write("user:1", "new_value", expires_in: 300)

    assert_equal "new_value", mock_store.read("test:user:1")
    assert_equal 300, mock_store.written_keys.last[:expires_in]
  end

  test "delete removes from underlying store with namespaced key" do
    mock_store = MockStore.new
    cache_aside = CacheAside.new(store: mock_store, namespace: "test")

    mock_store.write("test:user:1", "value")
    cache_aside.delete("user:1")

    assert_nil mock_store.read("test:user:1")
  end
end
