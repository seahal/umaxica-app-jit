ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

if ENV["COVERAGE"].present?
  require "simplecov"
  SimpleCov.start "rails" do
    enable_coverage :branch
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors) if ENV["COVERAGE"].blank?

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
