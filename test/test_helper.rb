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
if defined?(UserActivityEvent)
  UserActivityEvent.ensure_defaults!
end
if defined?(UserActivityLevel)
  UserActivityLevel.ensure_defaults!
end
if defined?(StaffActivityLevel)
  StaffActivityLevel.find_or_create_by!(id: StaffActivityLevel::NEYO)
end
if defined?(UserActivityEvent)
  [
    UserActivityEvent::USER_SECRET_CREATED,
    UserActivityEvent::USER_SECRET_REMOVED,
    UserActivityEvent::USER_SECRET_UPDATED,
  ].each { |id| UserActivityEvent.find_or_create_by!(id: id) }
end
if defined?(StaffActivityEvent)
  [
    StaffActivityEvent::STAFF_SECRET_CREATED,
    StaffActivityEvent::STAFF_SECRET_REMOVED,
    StaffActivityEvent::STAFF_SECRET_UPDATED,
  ].each { |id| StaffActivityEvent.find_or_create_by!(id: id) }
end
if defined?(AppPreferenceActivityLevel)
  AppPreferenceActivityLevel.find_or_create_by!(id: AppPreferenceActivityLevel::INFO)
end
if defined?(ComPreferenceActivityLevel)
  ComPreferenceActivityLevel.find_or_create_by!(id: ComPreferenceActivityLevel::INFO)
end
if defined?(OrgPreferenceActivityLevel)
  OrgPreferenceActivityLevel.find_or_create_by!(id: OrgPreferenceActivityLevel::INFO)
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
    add_filter "bin/"
    add_filter "docs/"
    add_filter "log/"
    add_filter "docker/"
    add_filter "dependency/"
    add_filter "public/"
    add_filter "node_modules/"
    add_filter "vendor/"

    # Redundant schema files
    add_filter "db/schema.rb"
    add_filter "db/activity_schema.rb"
    add_filter "db/avatar_schema.rb"
    add_filter "db/behavior_schema.rb"
    add_filter "db/billing_schema.rb"
    add_filter "db/cache_schema.rb"
    add_filter "db/default_schema.rb"
    add_filter "db/document_schema.rb"
    add_filter "db/guest_schema.rb"
    add_filter "db/identifier_schema.rb"
    add_filter "db/message_schema.rb"
    add_filter "db/news_schema.rb"
    add_filter "db/notification_schema.rb"
    add_filter "db/occurrence_schema.rb"
    add_filter "db/operator_schema.rb"
    add_filter "db/preference_schema.rb"
    add_filter "db/principal_schema.rb"
    add_filter "db/profile_schema.rb"
    add_filter "db/queue_schema.rb"
    add_filter "db/storage_schema.rb"
    add_filter "db/token_schema.rb"
  end
end

class ActiveSupport::TestCase
  include ActiveJob::TestHelper

  self.use_transactional_tests = false if ENV["SKIP_DB"] == "1" && respond_to?(:use_transactional_tests=)

  fixtures :staff_token_kinds,
           :staff_token_statuses,
           :staff_statuses,
           :staff_email_statuses,
           :staffs,
           :staff_tokens,
           :user_token_kinds,
           :user_token_statuses,
           :user_statuses,
           :users,
           :user_one_time_password_statuses,
           :user_email_statuses,
           :user_telephone_statuses,
           :staff_telephone_statuses,
           :user_passkey_statuses,
           :app_preference_statuses,
           :com_preference_statuses,
           :org_preference_statuses,
           :com_preferences,
           :com_preference_colorthemes,
           :app_document_statuses,
           :org_document_statuses,
           :com_document_statuses,
           :com_timeline_statuses,
           :app_timeline_statuses,
           :com_document_behavior_levels,
           :org_document_behavior_levels,
           :org_document_behavior_events,
           :app_timeline_behavior_events,
           :app_timeline_behavior_levels,
           :com_preference_activity_events,
           :com_preference_activity_levels,
           :area_occurrence_statuses,
           :area_occurrences,
           :app_documents,
           :org_documents,
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
           :user_client_suspensions,
           :app_contact_categories,
           :app_contact_statuses,
           :com_contact_statuses,
           :org_contact_statuses,
           :handle_statuses,
           :handles,
           :avatar_capabilities,
           :avatar_membership_statuses,
           :avatar_moniker_statuses,
           :avatar_ownership_statuses,
           :avatars,
           :post_statuses,
           :post_review_statuses,
           :app_preference_activity_levels,
           :org_preference_activity_levels,
           :staff_activity_levels,
           :user_activity_levels,
           :org_timeline_statuses unless ENV["SKIP_DB"] == "1"

  # Load fixtures only when explicitly needed in individual test files
  # instead of loading all fixtures globally
  # To use fixtures in a specific test file, add:
  # fixtures :all unless ENV["SKIP_DB"] == "1"

  # Helper to create a user with a verified email for tests requiring this prerequisite.
  def create_verified_user_with_email(email_address: "test@example.com", status: UserStatus::NEYO)
    user = User.create!(
      status_id: status, public_id: SecureRandom.hex(10), created_at: Time.current,
      updated_at: Time.current,
    )
    UserEmail.create!(
      user: user,
      address: email_address,
      user_email_status_id: UserEmailStatus::VERIFIED, # Using the confirmed ID for VERIFIED
      created_at: Time.current,
      updated_at: Time.current,
    )
    user # Return the user object
  end
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
