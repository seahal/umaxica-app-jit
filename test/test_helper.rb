# frozen_string_literal: true

# simplecov
require "simplecov"
SimpleCov.start "rails" do
  add_filter "/vendor/"
  add_filter "/bin/"
  add_filter "/db/"
  add_filter "/config/"
  add_filter "/spec/"
  add_filter "/test/"
  add_filter "/tmp/"
  add_filter "/log/"
  add_filter "/.bundle/"

  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Services", "app/services"
  add_group "Helpers", "app/helpers"
  add_group "Mailers", "app/mailers"
  add_group "Jobs", "app/jobs"
  add_group "Views", "app/views"
  add_group "Policies", "app/policies"
  add_group "Uploaders", "app/uploaders"
  add_group "Concerns", "app/controllers/concerns"
  add_group "Model Concerns", "app/models/concerns"

  minimum_coverage 80
  minimum_coverage_by_file 60

  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::SimpleFormatter
  ])
end

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
    setup do
      redis_host = File.exist?("/.dockerenv") ? ENV["REDIS_SESSION_URL"] : "localhost"
      redis_config = RedisClient.config(
        host: redis_host,
        port: 6379,
        db: 0
      )

      # Create a connection and clear the database
      redis_client = redis_config.new_client

      # Clear all keys in the test database
      redis_client.call("FLUSHALL")
    end
  end
end
