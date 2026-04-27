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

# Set jump URLs for tests
ENV["JUMP_CORPORATE_URL"] ||= "jump.example.com"
ENV["JUMP_SERVICE_URL"] ||= "jump.example.app"
ENV["JUMP_STAFF_URL"] ||= "jump.example.org"
require "active_model"
coverage_enabled = ActiveModel::Type::Boolean.new.cast(ENV["COVERAGE"])
require_relative "support/simplecov_setup" if coverage_enabled

require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").each do |file|
  require file
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors, work_stealing: true)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
