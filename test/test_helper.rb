ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").each { |f| require f }

if ENV["COVERAGE"].present?
  require "simplecov"
  SimpleCov.start "rails" do
    enable_coverage :branch
  end
end

module ActiveSupport
  class TestCase
    # # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors) if ENV["COVERAGE"].blank?

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end
