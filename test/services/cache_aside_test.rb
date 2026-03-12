# typed: false
# frozen_string_literal: true

require "test_helper"

class CacheAsideTest < ActiveSupport::TestCase
  class MockStore
    def initialize
      @data = {}
    end

    def fetch(key, expires_in:, race_condition_ttl:)
      @data[key] ||= yield
    end

    def read(key)
      @data[key]
    end

    def write(key, value, expires_in: nil)
      @data[key] = value
    end

    delegate :delete, to: :@data
  end

  test "fetch calls underlying store with namespaced key" do
    mock_store = MockStore.new
    cache_aside = CacheAside.new(store: mock_store, namespace: "test")

    result = cache_aside.fetch("user:1", expires_in: 60) { "value" }

    assert_equal "value", result
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
  end

  test "delete removes from underlying store with namespaced key" do
    mock_store = MockStore.new
    cache_aside = CacheAside.new(store: mock_store, namespace: "test")

    mock_store.write("test:user:1", "value")
    cache_aside.delete("user:1")

    assert_nil mock_store.read("test:user:1")
  end
end
