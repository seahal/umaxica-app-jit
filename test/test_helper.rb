# typed: false
# frozen_string_literal: true

require "active_model"

coverage_enabled = ActiveModel::Type::Boolean.new.cast(ENV["COVERAGE"])
require_relative "support/simplecov_setup" if coverage_enabled

ENV["RAILS_ENV"] ||= "test"
ENV["SIGN_SERVICE_URL"] ||= "sign.app.localhost"
ENV["SIGN_STAFF_URL"] ||= "sign.org.localhost"
ENV["CORE_SERVICE_URL"] ||= "www.app.localhost"
ENV["CORE_STAFF_URL"] ||= "www.org.localhost"
ENV["CORE_CORPORATE_URL"] ||= "www.com.localhost"
ENV["APEX_SERVICE_URL"] ||= "app.localhost"
ENV["APEX_STAFF_URL"] ||= "org.localhost"
ENV["APEX_CORPORATE_URL"] ||= "com.localhost"
ENV["DOCS_SERVICE_URL"] ||= "docs.app.localhost"
ENV["DOCS_STAFF_URL"] ||= "docs.org.localhost"
ENV["DOCS_CORPORATE_URL"] ||= "docs.com.localhost"
ENV["NEWS_SERVICE_URL"] ||= "news.app.localhost"
ENV["NEWS_STAFF_URL"] ||= "news.org.localhost"
ENV["NEWS_CORPORATE_URL"] ||= "news.com.localhost"
ENV["HELP_SERVICE_URL"] ||= "help.app.localhost"
ENV["HELP_STAFF_URL"] ||= "help.org.localhost"
ENV["HELP_CORPORATE_URL"] ||= "help.com.localhost"
ENV["REGION_CODE"] ||= "jp"
ENV["TRUSTED_ORIGINS"] ||= "http://sign.app.localhost:3001,http://sign.org.localhost:3001"
ENV["PREFERENCE_JWT_AUDIENCES"] ||= "app.localhost,org.localhost,com.localhost"

require_relative "../config/environment"
require "rails/test_help"

# Load all support files
Rails.root.glob("test/support/**/*.rb").each { |f| require f }

module ActiveSupport
  class TestCase
    coverage_enabled = ActiveModel::Type::Boolean.new.cast(ENV["COVERAGE"])
    max_parallel_workers = 32

    # Use a single worker for coverage runs to keep SimpleCov results deterministic.
    # Respect PARALLEL_WORKERS when provided, otherwise use max available CPU workers.
    # Cap workers below 20 to avoid over-parallelizing test runs.
    # NOTE: Multi-process parallelism (the default) forks the process. Each worker gets
    # its own database connection pool and transaction, so fixture isolation is maintained.
    # If you observe flaky tests with shared state (e.g. Rails.cache, ENV), consider
    # running with PARALLEL_WORKERS=1 to isolate the issue.
    requested_workers = Integer(ENV["PARALLEL_WORKERS"], exception: false)
    workers =
      if coverage_enabled
        1
      elsif requested_workers&.positive?
        [requested_workers, max_parallel_workers].min
      else
        [Etc.nprocessors - 1, max_parallel_workers].min
      end
    parallelize(workers: workers)

    self.use_transactional_tests = true

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all unless ENV["SKIP_DB"] == "1"

    include ActiveJob::TestHelper
  end
end
