# frozen_string_literal: true

require "active_model"

require_relative "support/simplecov_setup" unless ActiveModel::Type::Boolean.new.cast(ENV["COVERAGE"])

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
ENV["COOKIE_DOMAIN_APP"] ||= "app.localhost"
ENV["COOKIE_DOMAIN_COM"] ||= "com.localhost"
ENV["COOKIE_DOMAIN_ORG"] ||= "org.localhost"

require_relative "../config/environment"
require "rails/test_help"

# Load all support files
Rails.root.glob("test/support/**/*.rb").each { |f| require f }

module ActiveSupport
  class TestCase
    # Run tests in parallel with threads (threads avoid per-process DB duplication
    # which is costly with 20+ databases).
    parallelize(workers: 16)

    self.use_transactional_tests = true

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all unless ENV["SKIP_DB"] == "1"

    include ActiveJob::TestHelper
  end
end
