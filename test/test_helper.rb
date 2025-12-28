# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").each { |f| require f }

if ENV["RAILS_ENV"] == "test"
  require "simplecov"

  # Configure to allow coverage measurement even with parallelization
  # SimpleCov.command_name "minitest_#{Process.pid}#{ENV["TEST_ENV_NUMBER"]}"

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

    # Exclude annotate configuration file as it is only for configuration
    # add_filter "lib/tasks/auto_annotate_models.rake"
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # Note: Only loading fixtures that actually exist to avoid nil errors during teardown
    fixtures :all

    # include ActiveJob::TestHelper
  end
end

# module LayoutAssertions
#   def assert_layout_contract
#     assert_select "head", count: 1 do
#       assert_select "link[rel=?][href*=?]", "stylesheet", "application", count: 1
#       assert_select "link[rel=?][href*=?]", "stylesheet", "tailwind", count: 1
#     end

#     assert_select "header", minimum: 1
#     assert_select "main", count: 1
#     assert_select "footer", count: 1 do
#       assert_select "nav", count: 1
#       assert_select "small", text: /^©/
#     end
#   end
# end

# class ActionDispatch::IntegrationTest
#   include LayoutAssertions
# end
