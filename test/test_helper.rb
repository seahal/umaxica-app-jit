# typed: false
# frozen_string_literal: true

require "active_model"

coverage_enabled = ActiveModel::Type::Boolean.new.cast(ENV["COVERAGE"])
require_relative "support/simplecov_setup" if coverage_enabled

ENV["RAILS_ENV"] = "test"
ENV["SIGN_SERVICE_URL"] = "sign.app.localhost"
ENV["SIGN_CORPORATE_URL"] = "sign.com.localhost"
ENV["SIGN_STAFF_URL"] = "sign.org.localhost"
ENV["CORE_SERVICE_URL"] = "ww.app.localhost"
ENV["CORE_STAFF_URL"] = "ww.org.localhost"
ENV["CORE_CORPORATE_URL"] = "ww.com.localhost"
ENV["APEX_SERVICE_URL"] = "app.localhost"
ENV["APEX_STAFF_URL"] = "org.localhost"
ENV["APEX_CORPORATE_URL"] = "com.localhost"
ENV["DOCS_SERVICE_URL"] = "docs.app.localhost"
ENV["DOCS_STAFF_URL"] = "docs.org.localhost"
ENV["DOCS_CORPORATE_URL"] = "docs.com.localhost"
ENV["NEWS_SERVICE_URL"] = "news.app.localhost"
ENV["NEWS_STAFF_URL"] = "news.org.localhost"
ENV["NEWS_CORPORATE_URL"] = "news.com.localhost"
ENV["HELP_SERVICE_URL"] = "help.app.localhost"
ENV["HELP_STAFF_URL"] = "help.org.localhost"
ENV["HELP_CORPORATE_URL"] = "help.com.localhost"
ENV["REGION_CODE"] = "all"
ENV["TRUSTED_ORIGINS"] = "http://sign.app.localhost:3001,http://sign.com.localhost:3001,http://sign.org.localhost:3001"
ENV["PREFERENCE_JWT_AUDIENCES"] = "app.localhost,org.localhost,com.localhost"

require_relative "../config/environment"
require "rails/test_help"

# Load all support files
Rails.root.glob("test/support/**/*.rb").each { |f| require f }

module TestRateLimitReset
  module_function

  def clear!
    clear_rate_limit_store!
    clear_cache_rate_limit_state!
  end

  def clear_rate_limit_store!
    return unless defined?(RateLimit)

    RateLimit.store.clear
  rescue StandardError => e
    warn("[test_helper] failed to clear RateLimit store: #{e.class}: #{e.message}")
  end

  def clear_cache_rate_limit_state!
    return unless defined?(Rails.cache)

    Rails.cache.clear
  rescue NotImplementedError
    nil
  rescue StandardError => e
    warn("[test_helper] failed to clear Rails.cache rate limit state: #{e.class}: #{e.message}")
  end
end

module ActiveSupport
  class TestCase
    coverage_enabled = ActiveModel::Type::Boolean.new.cast(ENV["COVERAGE"])

    # Keep coverage runs serial for deterministic SimpleCov results.
    # Otherwise prefer an explicit PARALLEL_WORKERS override, then a physical-core estimate.
    # If detection fails, TestSupport::CpuWorkers falls back to a safe integer >= 1.
    # NOTE: Multi-process parallelism (the default) forks the process. Each worker gets
    # its own database connection pool and transaction, so fixture isolation is maintained.
    # If you observe flaky tests with shared state (e.g. Rails.cache, ENV), consider
    # running with PARALLEL_WORKERS=1 to isolate the issue.
    workers = coverage_enabled ? 1 : TestSupport::CpuWorkers.detect

    unless coverage_enabled
      parallelize(workers: workers)
      parallelize_setup do |_worker|
        TestRateLimitReset.clear!
      end
    end

    self.use_transactional_tests = true

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all unless ENV["SKIP_DB"] == "1"

    include ActiveJob::TestHelper
    include ActiveSupport::Testing::TimeHelpers

    setup do
      TestRateLimitReset.clear!
    end
  end
end
