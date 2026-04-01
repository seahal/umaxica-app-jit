# typed: false
# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

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
