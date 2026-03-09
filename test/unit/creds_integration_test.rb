# typed: false
# frozen_string_literal: true

require "test_helper"

class CredsIntegrationTest < ActiveSupport::TestCase
  # Verify that all credential keys migrated to Rails.app.creds
  # are actually resolvable in the test environment.

  self.use_transactional_tests = false
  self.fixture_table_names = []

  # -- require keys (must be present, raise if missing) -------------------

  test "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY is present" do
    assert_present Rails.app.creds.require(:ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY)
  end

  test "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY is present" do
    assert_present Rails.app.creds.require(:ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY)
  end

  test "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT is present" do
    assert_present Rails.app.creds.require(:ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT)
  end

  test "JWT_AUTH_PRIVATE_KEY is present" do
    assert_present Rails.app.creds.require(:JWT_AUTH_PRIVATE_KEY)
  end

  test "JWT_AUTH_PUBLIC_KEY is present" do
    assert_present Rails.app.creds.require(:JWT_AUTH_PUBLIC_KEY)
  end

  test "RESEND_SMTP_PASSWORD is present" do
    assert_present Rails.app.creds.require(:RESEND_SMTP_PASSWORD)
  end

  test "SMTP_FROM_ADDRESS is present" do
    assert_present Rails.app.creds.require(:SMTP_FROM_ADDRESS)
  end

  # -- option keys (present in test credentials) --------------------------

  test "JWT_PREFERENCE_PRIVATE_KEY is present" do
    assert_present Rails.app.creds.option(:JWT_PREFERENCE_PRIVATE_KEY)
  end

  test "JWT_PREFERENCE_PUBLIC_KEY is present" do
    assert_present Rails.app.creds.option(:JWT_PREFERENCE_PUBLIC_KEY)
  end

  test "SENTRY_DSN_CONFIG is present" do
    assert_present Rails.app.creds.option(:SENTRY_DSN_CONFIG)
  end

  test "CLOUDFLARE_TURNSTILE_VISIBLE_SITE_KEY is present" do
    assert_present Rails.app.creds.option(:CLOUDFLARE_TURNSTILE_VISIBLE_SITE_KEY)
  end

  test "CLOUDFLARE_TURNSTILE_VISIBLE_SECRET_KEY is present" do
    assert_present Rails.app.creds.option(:CLOUDFLARE_TURNSTILE_VISIBLE_SECRET_KEY)
  end

  test "CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY is present" do
    assert_present Rails.app.creds.option(:CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY)
  end

  test "CLOUDFLARE_TURNSTILE_SECRET_STEALTH_KEY is present" do
    assert_present Rails.app.creds.option(:CLOUDFLARE_TURNSTILE_SECRET_STEALTH_KEY)
  end

  test "OMNI_AUTH_GOOGLE_CLIENT_ID is present" do
    assert_present Rails.app.creds.option(:OMNI_AUTH_GOOGLE_CLIENT_ID)
  end

  test "OMNI_AUTH_GOOGLE_CLIENT_SECRET is present" do
    assert_present Rails.app.creds.option(:OMNI_AUTH_GOOGLE_CLIENT_SECRET)
  end

  test "OMNI_AUTH_APPLE_CLIENT_ID is present" do
    assert_present Rails.app.creds.option(:OMNI_AUTH_APPLE_CLIENT_ID)
  end

  test "OMNI_AUTH_APPLE_TEAM_ID is present" do
    assert_present Rails.app.creds.option(:OMNI_AUTH_APPLE_TEAM_ID)
  end

  test "OMNI_AUTH_APPLE_KEY_ID is present" do
    assert_present Rails.app.creds.option(:OMNI_AUTH_APPLE_KEY_ID)
  end

  test "OMNI_AUTH_APPLE_PRIVATE_KEY is present" do
    assert_present Rails.app.creds.option(:OMNI_AUTH_APPLE_PRIVATE_KEY)
  end

  # -- option keys with fallback (may not be in credentials) --------------

  test "OCCURRENCE_HMAC_SECRET is resolvable" do
    value = Rails.app.creds.option(:OCCURRENCE_HMAC_SECRET)

    assert_not_nil value, "OCCURRENCE_HMAC_SECRET should be set in test credentials or ENV"
  end

  test "REDIS_NORMAL_URL is resolvable with default" do
    value = Rails.app.creds.option(:REDIS_NORMAL_URL, default: "redis://localhost:6379/0")

    assert_present value
  end

  private

  def assert_present(value)
    assert_predicate value, :present?, "Expected value to be present, got: #{value.inspect}"
  end
end
