# frozen_string_literal: true

# Configure Solid Cache to use the cache database
SolidCache.configuration = SolidCache::Configuration.new(
  connects_to: { database: { writing: :cache, reading: :cache_replica } },
  size_estimate_samples: 10_000
)
