# frozen_string_literal: true

class RuntimeConfig
  TTL = 30.seconds

  CACHE = CacheAside.new(store: RUNTIME_FILE_CACHE, namespace: "cfg")

  class << self
    def get(key, expires_in: TTL)
      CACHE.fetch(key, expires_in: expires_in) do
        fetch_from_source!(key)
      end
    rescue => e
      safe_default(key, error: e)
    end

    private

    def fetch_from_source!(key)
      # Example:
      # Setting.fetch!(key).value
      raise NotImplementedError, "define fetch_from_source! for #{key}"
    end

    def safe_default(key, error:)
      # Example (adjust based on requirements)
      # key == "maintenance_mode" ? true : false
      nil
    end
  end
end
