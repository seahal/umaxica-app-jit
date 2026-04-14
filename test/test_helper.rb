# typed: false
# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

# Set side URLs for tests
ENV["SIDE_CORPORATE_URL"] ||= "news.com.localhost"
ENV["SIDE_SERVICE_URL"] ||= "news.app.localhost"
ENV["SIDE_STAFF_URL"] ||= "news.org.localhost"

# Set apex URLs for tests
ENV["APEX_CORPORATE_URL"] ||= "com.localhost"
ENV["APEX_SERVICE_URL"] ||= "app.localhost"
ENV["APEX_STAFF_URL"] ||= "org.localhost"

# Set docs URLs for tests
ENV["DOCS_CORPORATE_URL"] ||= "docs.com.localhost"
ENV["DOCS_SERVICE_URL"] ||= "docs.app.localhost"
ENV["DOCS_STAFF_URL"] ||= "docs.org.localhost"

# Set sign URLs for tests
ENV["SIGN_CORPORATE_URL"] ||= "sign.com.localhost"
ENV["SIGN_SERVICE_URL"] ||= "sign.app.localhost"
ENV["SIGN_STAFF_URL"] ||= "sign.org.localhost"

# Set main URLs for tests
ENV["MAIN_CORPORATE_URL"] ||=
  (ENV["CORE_CORPORATE_URL"] unless ENV["CORE_CORPORATE_URL"].to_s.empty?) || "www.com.localhost"
ENV["MAIN_SERVICE_URL"] ||= (ENV["CORE_SERVICE_URL"] unless ENV["CORE_SERVICE_URL"].to_s.empty?) || "www.app.localhost"
ENV["MAIN_STAFF_URL"] ||= (ENV["CORE_STAFF_URL"] unless ENV["CORE_STAFF_URL"].to_s.empty?) || "www.org.localhost"
require "active_model"
COVERAGE_DISABLED = ActiveModel::Type::Boolean.new.cast(ENV["COVERAGE"] == "false")
require_relative "support/simplecov_setup" unless COVERAGE_DISABLED

require_relative "../config/environment"
require "ostruct"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").each do |file|
  require file
end

# Include Engine route helpers for controllers and action_view helpers only.
# Do NOT include in action_dispatch_integration_test, as the main app routes
# already include these when engines are mounted at "/" with proper namespacing.
[
  Jit::Signature::Engine.routes.url_helpers,
  Jit::World::Engine.routes.url_helpers,
  Jit::Station::Engine.routes.url_helpers,
  Jit::Press::Engine.routes.url_helpers,
].each do |route_helpers|
  ActiveSupport.on_load(:action_controller) { include route_helpers }
  ActionController::Base.helper(route_helpers)
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
