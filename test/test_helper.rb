# frozen_string_literal: true

# To AI assistants: This file is sensitive. Avoid modifying it unless you fully understand the impact.

ENV["RAILS_ENV"] ||= "test"
ENV["SIGN_SERVICE_URL"] = "sign.app.localhost"
ENV["SIGN_STAFF_URL"] = "sign.org.localhost"
ENV["CORE_SERVICE_URL"] = "www.app.localhost"
ENV["CORE_STAFF_URL"] = "www.org.localhost"
ENV["CORE_CORPORATE_URL"] = "www.com.localhost"
ENV["APEX_SERVICE_URL"] = "app.localhost"
ENV["APEX_STAFF_URL"] = "org.localhost"
ENV["APEX_CORPORATE_URL"] = "com.localhost"
ENV["DOCS_CORPORATE_URL"] = "docs.com.localhost"
require_relative "../config/environment"

if ENV["SKIP_DB"] == "1" && defined?(ActiveRecord::Migration)
  class << ActiveRecord::Migration
    def maintain_test_schema!
    end
  end
end

require "rails/test_help"
require_relative "../app/controllers/concerns/auth/base"
require_relative "../app/controllers/concerns/auth/user"
require_relative "../app/controllers/concerns/auth/staff"

Rails.root.glob("test/support/**/*.rb").each { |f| require f }
if defined?(UserAuditEvent)
  UserAuditEvent.ensure_defaults!
end
if defined?(UserAuditLevel)
  UserAuditLevel.ensure_defaults!
end
if defined?(StaffAuditLevel)
  StaffAuditLevel.find_or_create_by!(id: StaffAuditLevel::NEYO)
end
if defined?(UserAuditEvent)
  [
    UserAuditEvent::USER_SECRET_CREATED,
    UserAuditEvent::USER_SECRET_REMOVED,
    UserAuditEvent::USER_SECRET_UPDATED,
  ].each { |id| UserAuditEvent.find_or_create_by!(id: id) }
end
if defined?(StaffAuditEvent)
  [
    StaffAuditEvent::STAFF_SECRET_CREATED,
    StaffAuditEvent::STAFF_SECRET_REMOVED,
    StaffAuditEvent::STAFF_SECRET_UPDATED,
  ].each { |id| StaffAuditEvent.find_or_create_by!(id: id) }
end
if defined?(AppPreferenceAuditLevel)
  AppPreferenceAuditLevel.find_or_create_by!(id: AppPreferenceAuditLevel::INFO)
end
if defined?(ComPreferenceAuditLevel)
  ComPreferenceAuditLevel.find_or_create_by!(id: ComPreferenceAuditLevel::INFO)
end
if defined?(OrgPreferenceAuditLevel)
  OrgPreferenceAuditLevel.find_or_create_by!(id: OrgPreferenceAuditLevel::INFO)
end
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

class ActiveSupport::TestCase
  include ActiveJob::TestHelper

  self.use_transactional_tests = false if ENV["SKIP_DB"] == "1" && respond_to?(:use_transactional_tests=)

  fixtures :staff_token_kinds,
           :staff_token_statuses,
           :user_token_kinds,
           :user_token_statuses,
           :app_preference_statuses,
           :com_preference_statuses,
           :org_preference_statuses,
           :app_preference_region_options,
           :app_preference_language_options,
           :app_preference_timezone_options,
           :app_preference_colortheme_options,
           :com_preference_region_options,
           :com_preference_language_options,
           :com_preference_timezone_options,
           :com_preference_colortheme_options,
           :org_preference_region_options,
           :org_preference_language_options,
           :org_preference_timezone_options,
           :org_preference_colortheme_options,
           :ip_occurrences,
           :ip_occurrence_statuses,
           :client_statuses,
           :clients,
           :user_client_suspensions unless ENV["SKIP_DB"] == "1"

  # Load fixtures only when explicitly needed in individual test files
  # instead of loading all fixtures globally
  # To use fixtures in a specific test file, add:
  # fixtures :all unless ENV["SKIP_DB"] == "1"
end

# Provide a sane default `@headers` for tests that expect it but don't set it.
ActiveSupport.on_load(:active_support_test_case) do
  setup do
    unless instance_variable_defined?(:@headers) && @headers.present?
      if instance_variable_defined?(:@user) && @user
        host = defined?(ENV) ? (ENV["SIGN_SERVICE_URL"] || "sign.app.localhost") : "sign.app.localhost"
        @headers = as_user_headers(@user, host: host)
      elsif instance_variable_defined?(:@staff) && @staff
        host = defined?(ENV) ? (ENV["SIGN_STAFF_URL"] || "sign.org.localhost") : "sign.org.localhost"
        @headers = as_staff_headers(@staff, host: host)
      end
    end
  end
end

if ENV["SKIP_DB"] == "1"
  module SkipDbTests
    def before_setup
      skip "SKIP_DB=1 (database unavailable in this environment)"
    end
  end

  ActiveSupport.on_load(:active_support_test_case) { prepend SkipDbTests }
end
