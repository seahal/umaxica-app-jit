# typed: false
# frozen_string_literal: true

module RateLimitStoreReset
  def setup
    super
    RateLimit.store.clear if defined?(RateLimit)
  end
end

ActiveSupport.on_load(:active_support_test_case) { prepend RateLimitStoreReset }
