# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").each { |f| require f }

if ENV["RAILS_ENV"] == "test" && ENV["COVERAGE"] != "false"
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

# rubocop:disable Lint/EmptyClass
module ActiveSupport
  class TestCase
    include ActiveJob::TestHelper

    # Run tests in parallel with specified workers
    # parallelize(workers: 16)

    # Users are created programmatically via UserFixtures module to avoid circular dependencies
    fixtures :all

    # Class-level flag to ensure NEYO data is seeded only once per test run
    @@neyo_seeded = false
    @@neyo_seed_mutex = Mutex.new

    # Seed NEYO reference data before fixtures are loaded
    # IMPORTANT: Must use before_setup, not setup, to run before fixture loading
    # Optimized to run only once per test suite instead of before every test
    def before_setup
      @@neyo_seed_mutex.synchronize do
        unless @@neyo_seeded
          seed_neyo_reference_data
          @@neyo_seeded = true
        end
      end
      super
    end

    private

    def seed_neyo_reference_data
      # GUESTS - Contact Categories & Statuses
      [
        { db: GuestsRecord,
          table: "app_contact_categories",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: GuestsRecord,
          table: "com_contact_categories",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: GuestsRecord,
          table: "org_contact_categories",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: GuestsRecord, table: "app_contact_statuses", columns: "id", values: "'NEYO'" },
        { db: GuestsRecord, table: "app_contact_statuses", columns: "id", values: "'SET_UP'" },
        { db: GuestsRecord, table: "com_contact_statuses", columns: "id", values: "'NEYO'" },
        { db: GuestsRecord, table: "com_contact_statuses", columns: "id", values: "'SET_UP'" },
        { db: GuestsRecord, table: "org_contact_statuses", columns: "id", values: "'NEYO'" },
        { db: GuestsRecord, table: "org_contact_statuses", columns: "id", values: "'SET_UP'" },
        # NEWS - Timeline Statuses
        { db: NewsRecord,
          table: "app_timeline_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: NewsRecord,
          table: "com_timeline_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: NewsRecord,
          table: "org_timeline_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        # DOCUMENTS - Document Statuses
        { db: DocumentRecord,
          table: "app_document_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: DocumentRecord,
          table: "com_document_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: DocumentRecord,
          table: "org_document_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        # IDENTITIES - Identity Statuses
        { db: IdentitiesRecord, table: "staff_identity_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "user_identity_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "user_identity_statuses", columns: "id", values: "'PRE_WITHDRAWAL_CONDITION'" },
        { db: IdentitiesRecord, table: "user_identity_statuses", columns: "id", values: "'VERIFIED_WITH_SIGN_UP'" },
        { db: IdentitiesRecord, table: "user_identity_statuses", columns: "id", values: "'ACTIVE'" },
        { db: IdentitiesRecord, table: "staff_identity_email_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "staff_identity_email_statuses", columns: "id", values: "'UNVERIFIED'" },
        { db: IdentitiesRecord, table: "staff_identity_telephone_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "staff_identity_telephone_statuses", columns: "id", values: "'UNVERIFIED'" },
        { db: IdentitiesRecord, table: "user_identity_email_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "user_identity_email_statuses", columns: "id", values: "'UNVERIFIED'" },
        { db: IdentitiesRecord, table: "user_identity_telephone_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "user_identity_telephone_statuses", columns: "id", values: "'UNVERIFIED'" },
        { db: IdentitiesRecord, table: "staff_identity_passkey_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "user_identity_passkey_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "user_identity_passkey_statuses", columns: "id", values: "'ACTIVE'" },
        { db: IdentitiesRecord, table: "staff_identity_secret_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "staff_identity_secret_statuses", columns: "id", values: "'ACTIVE'" },
        { db: IdentitiesRecord, table: "staff_identity_secret_statuses", columns: "id", values: "'USED'" },
        { db: IdentitiesRecord, table: "staff_identity_secret_statuses", columns: "id", values: "'EXPIRED'" },
        { db: IdentitiesRecord, table: "staff_identity_secret_statuses", columns: "id", values: "'REVOKED'" },
        { db: IdentitiesRecord, table: "staff_identity_secret_statuses", columns: "id", values: "'DELETED'" },
        { db: IdentitiesRecord, table: "user_identity_secret_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "user_identity_secret_statuses", columns: "id", values: "'ACTIVE'" },
        { db: IdentitiesRecord, table: "user_identity_secret_statuses", columns: "id", values: "'USED'" },
        { db: IdentitiesRecord, table: "user_identity_secret_statuses", columns: "id", values: "'EXPIRED'" },
        { db: IdentitiesRecord, table: "user_identity_secret_statuses", columns: "id", values: "'REVOKED'" },
        { db: IdentitiesRecord, table: "user_identity_secret_statuses", columns: "id", values: "'DELETED'" },
        { db: IdentitiesRecord,
          table: "user_identity_audit_levels",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_levels",
          columns: "id, created_at, updated_at",
          values: "'INFO', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_levels",
          columns: "id, created_at, updated_at",
          values: "'WARN', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_levels",
          columns: "id, created_at, updated_at",
          values: "'ERROR', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "staff_identity_audit_levels",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "staff_identity_audit_levels",
          columns: "id, created_at, updated_at",
          values: "'INFO', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "staff_identity_audit_levels",
          columns: "id, created_at, updated_at",
          values: "'WARN', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "staff_identity_audit_levels",
          columns: "id, created_at, updated_at",
          values: "'ERROR', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'LOGIN_SUCCESS', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'LOGIN_FAILURE', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'LOGGED_IN', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'LOGGED_OUT', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'LOGIN_FAILED', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'TOKEN_REFRESHED', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'SIGNED_UP_WITH_EMAIL', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'SIGNED_UP_WITH_TELEPHONE', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'SIGNED_UP_WITH_APPLE', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "user_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'AUTHORIZATION_FAILED', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "staff_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "staff_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'LOGIN_SUCCESS', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "staff_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'LOGIN_FAILURE', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "staff_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'LOGGED_IN', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "staff_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'LOGGED_OUT', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "staff_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'LOGIN_FAILED', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "staff_identity_audit_events",
          columns: "id, created_at, updated_at",
          values: "'AUTHORIZATION_FAILED', NOW(), NOW()", },
        { db: IdentitiesRecord, table: "user_identity_one_time_password_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "user_identity_one_time_password_statuses", columns: "id", values: "'ACTIVE'" },
        { db: IdentitiesRecord,
          table: "user_identity_one_time_password_statuses",
          columns: "id",
          values: "'INACTIVE'", },
        { db: IdentitiesRecord, table: "user_identity_one_time_password_statuses", columns: "id", values: "'REVOKED'" },
        { db: IdentitiesRecord, table: "user_identity_one_time_password_statuses", columns: "id", values: "'DELETED'" },
        { db: IdentitiesRecord, table: "user_identity_social_apple_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord, table: "user_identity_social_google_statuses", columns: "id", values: "'NEYO'" },
        { db: IdentitiesRecord,
          table: "avatar_membership_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "avatar_moniker_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "avatar_ownership_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "handle_assignment_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "handle_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "post_review_statuses",
          columns: "id, key, name, created_at, updated_at",
          values: "'NEYO', 'NEYO', 'None', NOW(), NOW()", },
        { db: IdentitiesRecord,
          table: "post_statuses",
          columns: "id, created_at, updated_at",
          values: "'NEYO', NOW(), NOW()", },
        # TOKENS - Token Statuses
        { db: TokensRecord, table: "user_token_statuses", columns: "id", values: "'NEYO'" },
        { db: TokensRecord, table: "user_token_statuses", columns: "id", values: "'ACTIVE'" },
        { db: TokensRecord, table: "staff_token_statuses", columns: "id", values: "'NEYO'" },
        { db: TokensRecord, table: "staff_token_statuses", columns: "id", values: "'ACTIVE'" },
        # UNIVERSALS - Occurrence Statuses
        { db: UniversalRecord,
          table: "area_occurrence_statuses",
          columns: "id",
          values: "'NEYO'", },
        { db: UniversalRecord,
          table: "domain_occurrence_statuses",
          columns: "id",
          values: "'NEYO'", },
        { db: UniversalRecord,
          table: "email_occurrence_statuses",
          columns: "id",
          values: "'NEYO'", },
        { db: UniversalRecord,
          table: "ip_occurrence_statuses",
          columns: "id",
          values: "'NEYO'", },
        { db: UniversalRecord,
          table: "staff_occurrence_statuses",
          columns: "id",
          values: "'NEYO'", },
        { db: UniversalRecord,
          table: "telephone_occurrence_statuses",
          columns: "id",
          values: "'NEYO'", },
        { db: UniversalRecord,
          table: "user_occurrence_statuses",
          columns: "id",
          values: "'NEYO'", },
        { db: UniversalRecord,
          table: "zip_occurrence_statuses",
          columns: "id",
          values: "'NEYO'", },
      ].each do |seed|
        seed[:db].connection.execute(
          "INSERT INTO #{seed[:table]} (#{seed[:columns]}) VALUES (#{seed[:values]}) " \
          "ON CONFLICT (id) DO NOTHING",
        )
      end
    rescue StandardError => e
      # Log errors during seeding for debugging
      warn "NEYO seed error: #{e.class}: #{e.message}"
      warn e.backtrace.first(5).join("\n")
    end
  end
end
