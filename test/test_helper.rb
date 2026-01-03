# frozen_string_literal: true

if ENV["RAILS_ENV"] == "test" && ENV["COVERAGE"] != "false"
  require "simplecov"

  SimpleCov.start "rails" do
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

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").each { |f| require f }

class ActiveSupport::TestCase
  include ActiveJob::TestHelper

  # Use database transactions to roll back changes after each test
  # self.use_transactional_tests = true

  # Load fixtures only when explicitly needed in individual test files
  # instead of loading all fixtures globally
  # To use fixtures in a specific test file, add:
  fixtures :all

  # Add more helper methods to be used by all tests here...
  # fixtures :all  # Disabled to avoid loading broken/incomplete fixtures globally
end
