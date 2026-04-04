# typed: false
# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

# Set side URLs for tests
ENV["SIDE_CORPORATE_URL"] ||= "news.com.localhost"
ENV["SIDE_SERVICE_URL"] ||= "news.app.localhost"
ENV["SIDE_STAFF_URL"] ||= "news.org.localhost"

# Set main URLs for tests
ENV["MAIN_CORPORATE_URL"] ||= "main.com.localhost"
ENV["MAIN_SERVICE_URL"] ||= "main.app.localhost"
ENV["MAIN_STAFF_URL"] ||= "main.org.localhost"
require "active_model"
COVERAGE_DISABLED = ActiveModel::Type::Boolean.new.cast(ENV["COVERAGE"] == "false")
require_relative "support/simplecov_setup" unless COVERAGE_DISABLED

require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").each do |file|
  require file
end

module ActiveSupport
  class TestCase
    # Keep coverage collection in a single process to avoid partial result conflicts.
    if COVERAGE_DISABLED
      # Run tests in parallel with specified workers
      parallelize(workers: :number_of_processors, work_stealing: true)
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Include TimeHelpers for freeze_time/travel_to support across all tests
    include ActiveSupport::Testing::TimeHelpers

    # Add more helper methods to be used by all tests here...
  end
end
