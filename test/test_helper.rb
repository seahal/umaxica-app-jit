# frozen_string_literal: true

# To AI assistants: This file is sensitive. Avoid modifying it unless you fully understand the impact.

ENV["RAILS_ENV"] ||= "test"
ENV["SIGN_SERVICE_URL"] = "sign.app.localhost"
ENV["SIGN_STAFF_URL"] = "sign.org.localhost"
ENV["CORE_SERVICE_URL"] = "www.app.localhost"
ENV["CORE_STAFF_URL"] = "www.org.localhost"
ENV["APEX_SERVICE_URL"] = "app.localhost"
ENV["APEX_STAFF_URL"] = "org.localhost"
ENV["APEX_CORPORATE_URL"] = "com.localhost"
require_relative "../config/environment"

if ENV["SKIP_DB"] == "1" && defined?(ActiveRecord::Migration)
  class << ActiveRecord::Migration
    def maintain_test_schema!
    end
  end
end

require "rails/test_help"
require_relative "../app/controllers/concerns/auth/base"
require_relative "../app/controllers/concerns/auth/user"
require_relative "../app/controllers/concerns/auth/staff"

Rails.root.glob("test/support/**/*.rb").each { |f| require f }
if ENV["RAILS_ENV"] == "test" && ENV["COVERAGE"] != "false"
  require "simplecov"

  SimpleCov.start "rails" do
    enable_coverage :branch
    filters.clear
    add_filter ".bundle/"
    add_filter "vendor/"
    add_filter "app/views/"
    add_filter "test/"
    add_filter "config/"
    add_filter "db/"
    add_filter "tmp/"
    add_filter "bin/"
    add_filter "docs/"
    add_filter "log/"
    add_filter "docker/"
  end
end

class ActiveSupport::TestCase
  include ActiveJob::TestHelper

  self.use_transactional_tests = false if ENV["SKIP_DB"] == "1" && respond_to?(:use_transactional_tests=)

  # Load fixtures only when explicitly needed in individual test files
  # instead of loading all fixtures globally
  # To use fixtures in a specific test file, add:
  # fixtures :all unless ENV["SKIP_DB"] == "1"
end

if ENV["SKIP_DB"] == "1"
  module SkipDbTests
    def before_setup
      skip "SKIP_DB=1 (database unavailable in this environment)"
    end
  end

  ActiveSupport.on_load(:active_support_test_case) { prepend SkipDbTests }
end
