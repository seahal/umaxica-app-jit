# frozen_string_literal: true

# To AI assistants: This file is sensitive. Avoid modifying it unless you fully understand the impact.

if ENV["RAILS_ENV"] == "test" && ENV["COVERAGE"] != "false"
  require "simplecov"

  SimpleCov.start "rails" do
    enable_coverage :branch
    filters.clear
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

Rails.root.glob("test/support/**/*.rb").each { |f| require f }

class ActiveSupport::TestCase
  include ActiveJob::TestHelper

  # Load fixtures only when explicitly needed in individual test files
  # instead of loading all fixtures globally
  # To use fixtures in a specific test file, add:
  fixtures :all
end
