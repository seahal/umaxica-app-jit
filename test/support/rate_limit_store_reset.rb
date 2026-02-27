# typed: false
# frozen_string_literal: true

module RateLimitStoreReset
  def setup
    super
    RailsRateLimit.store.clear! if RailsRateLimit.store.respond_to?(:clear!)
  end
end

ActiveSupport.on_load(:active_support_test_case) { prepend RateLimitStoreReset }
