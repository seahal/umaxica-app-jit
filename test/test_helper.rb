# frozen_string_literal: true

if ENV["RAILS_ENV"] == "test" && ENV["COVERAGE"] != "false"
  require "simplecov"

  SimpleCov.start "rails" do
    # Reset filters if you want to include files that are filtered by default
    filters.clear

    # Filter out files that should not be measured
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
CloudflareTurnstile.test_mode = true

# Rails root glob for support files
Rails.root.glob("test/support/**/*.rb").each { |f| require f }

module ActiveSupport
  class TestCase
    include ActiveJob::TestHelper

    # Run tests in parallel with specified workers
    # Use :number_of_processors to automatically detect CPU cores
    # parallelize(workers: :number_of_processors)

    # Use transactional tests for speed
    self.use_transactional_tests = true

    fixtures :all
  end
end
