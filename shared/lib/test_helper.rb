# typed: false
# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

# Set side URLs for tests
ENV["SIDE_CORPORATE_URL"] ||= "news.com.localhost"
ENV["SIDE_SERVICE_URL"] ||= "news.app.localhost"
ENV["SIDE_STAFF_URL"] ||= "news.org.localhost"

# Set identity sign URLs for tests
ENV["IDENTITY_SIGN_APP_URL"] ||= "sign.app.localhost"
ENV["IDENTITY_SIGN_COM_URL"] ||= "sign.com.localhost"
ENV["IDENTITY_SIGN_ORG_URL"] ||= "sign.org.localhost"
ENV["IDENTITY_SIGN_DEV_URL"] ||= "sign.dev.localhost"
ENV["IDENTITY_SIGN_NET_URL"] ||= "sign.net.localhost"

# Set acme URLs for tests
ENV["ZENITH_ACME_COM_URL"] ||= "com.localhost"
ENV["ZENITH_ACME_APP_URL"] ||= "app.localhost"
ENV["ZENITH_ACME_ORG_URL"] ||= "org.localhost"

# Set docs URLs for tests
ENV["DISTRIBUTOR_POST_COM_URL"] ||= "docs.com.localhost"
ENV["DISTRIBUTOR_POST_APP_URL"] ||= "docs.app.localhost"
ENV["DISTRIBUTOR_POST_ORG_URL"] ||= "docs.org.localhost"

# Set sign URLs for tests
ENV["IDENTITY_SIGN_COM_URL"] ||= "sign.com.localhost"
ENV["IDENTITY_SIGN_APP_URL"] ||= "sign.app.localhost"
ENV["IDENTITY_SIGN_ORG_URL"] ||= "sign.org.localhost"

# Set main URLs for tests
ENV["FOUNDATION_BASE_COM_URL"] ||= "base.com.localhost"
ENV["FOUNDATION_BASE_APP_URL"] ||= "base.app.localhost"
ENV["FOUNDATION_BASE_ORG_URL"] ||= "base.org.localhost"
ENV["FOUNDATION_BASE_DEV_URL"] ||= "base.dev.localhost"
require "active_model"
COVERAGE_DISABLED = ActiveModel::Type::Boolean.new.cast(ENV["COVERAGE"] == "false")
require_relative "support/simplecov_setup" unless COVERAGE_DISABLED

require File.expand_path("config/environment", Dir.pwd)
require "ostruct"
require "rails/test_help"

Dir[File.expand_path("support/**/*.rb", __dir__)].each do |file|
  require file
end

# Include TimeHelpers for freeze_time/travel_to support across all tests
include ActiveSupport::Testing::TimeHelpers

module ActiveSupport
  class TestCase
    # Add shared fixture path
    self.fixture_paths = [
      File.expand_path("../test/fixtures", __dir__),
    ]
    ActionDispatch::IntegrationTest.fixture_paths = fixture_paths if defined?(ActionDispatch::IntegrationTest)

    # Keep coverage collection in a single process to avoid partial result conflicts.
    if COVERAGE_DISABLED
      # Run tests in parallel with specified workers
      parallelize(workers: :number_of_processors, work_stealing: true)
    end

    # SETUP: Each app should define its own required fixtures
    # fixtures :all

    # Include TimeHelpers for freeze_time/travel_to support across all tests
    include ActiveSupport::Testing::TimeHelpers

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  setup :set_engine_host_from_test_path

  private

  def set_engine_host_from_test_path
    name = self.class.name || ""

    # Map namespace segments to ENV prefix and subdomain defaults
    engine_config = {
      "Sign" => { prefix: "IDENTITY_SIGN", sub: "sign" },
      "Acme" => { prefix: "ZENITH_ACME", sub: "" },
      "Base" => { prefix: "FOUNDATION_BASE", sub: "base" },
      "Post" => { prefix: "DISTRIBUTOR_POST", sub: "post" },
    }

    config = engine_config.find { |ns, _| name.include?(ns) }&.last
    config ||= engine_config["Acme"] if name.include?("Acme")

    surface_match = name.match(/(App|Com|Org|Net|Dev)/)
    surface = surface_match[1].upcase if surface_match

    return unless config && surface

    env_key = "#{config[:prefix]}_#{surface}_URL"
    host_val = ENV[env_key]

    if host_val.nil?
      sub = config[:sub]
      host_val = sub.empty? ? "#{surface.downcase}.localhost" : "#{sub}.#{surface.downcase}.localhost"
    end

    host!(host_val)

  end
end
