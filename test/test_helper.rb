# frozen_string_literal: true

require_relative "support/simplecov_setup"

ENV["RAILS_ENV"] ||= "test"
ENV["SIGN_SERVICE_URL"] ||= "sign.app.localhost"
ENV["SIGN_STAFF_URL"] ||= "sign.org.localhost"
ENV["CORE_SERVICE_URL"] ||= "www.app.localhost"
ENV["CORE_STAFF_URL"] ||= "www.org.localhost"
ENV["CORE_CORPORATE_URL"] ||= "www.com.localhost"
ENV["APEX_SERVICE_URL"] ||= "app.localhost"
ENV["APEX_STAFF_URL"] ||= "org.localhost"
ENV["APEX_CORPORATE_URL"] ||= "com.localhost"
ENV["DOCS_CORPORATE_URL"] ||= "docs.com.localhost"

require_relative "../config/environment"
require "rails/test_help"

# Load all support files
Rails.root.glob("test/support/**/*.rb").each { |f| require f }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    self.use_transactional_tests = true

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all unless ENV["SKIP_DB"] == "1"

    include ActiveJob::TestHelper
  end
end
