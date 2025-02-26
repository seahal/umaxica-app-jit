# frozen_string_literal: true

# require 'simplecov'
# SimpleCov.start 'rails' do
#   coverage_dir './tmp/coverage'
# end
require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests sign_in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures sign_in test/fixtures/*.yml for all tests sign_in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
