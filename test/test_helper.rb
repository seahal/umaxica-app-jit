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

  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests
  # For multi-database setup, fixtures need to be loaded per-test
  # rather than globally with `fixtures :all`
  fixtures :all
  self.use_transactional_tests = true

  # Helper method to load specific fixtures for multi-database tests
  def self.use_fixtures(*fixture_names)
    fixtures(*fixture_names)
  end

  # Add more helper methods to be used by all tests here...
end
