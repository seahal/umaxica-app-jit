# frozen_string_literal: true

# require 'simplecov'
# SimpleCov.start 'rails' do
#   coverage_dir './tmp/coverage'
# end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

REMIX_URL_PREFIX = ENV['REMIX_URL']

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
