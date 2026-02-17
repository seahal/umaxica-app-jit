# frozen_string_literal: true

class CacheAside
  def initialize(store:, namespace:)
    @store = store
    @namespace = namespace
  end

  def fetch(key, expires_in:, race_ttl: 2.seconds, &)
    namespaced = "#{@namespace}:#{key}"
    @store.fetch(namespaced, expires_in: expires_in, race_condition_ttl: race_ttl, &)
  end

  def read(key)
    @store.read("#{@namespace}:#{key}")
  end

  def write(key, value, expires_in: nil)
    @store.write("#{@namespace}:#{key}", value, expires_in: expires_in)
  end

  def delete(key)
    @store.delete("#{@namespace}:#{key}")
  end
end
