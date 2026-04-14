# typed: false
# frozen_string_literal: true

require "test_helper"
require "mailer_url_options_guard"

class MailerUrlOptionsGuardTest < ActiveSupport::TestCase
  test "validate! accepts allowed host and integer port" do
    assert_nil MailerUrlOptionsGuard.validate!(
      default_url_options: { host: "localhost", port: 3001 },
      allowed_hosts: %w(localhost),
    )
  end

  test "validate! rejects missing host" do
    error =
      assert_raises(MailerUrlOptionsGuard::InvalidDefaultUrlOptionsError) do
        MailerUrlOptionsGuard.validate!(default_url_options: { port: 3001 }, allowed_hosts: %w(localhost))
      end

    assert_includes error.message, "host is required"
  end

  test "validate! rejects scheme in host" do
    error =
      assert_raises(MailerUrlOptionsGuard::InvalidDefaultUrlOptionsError) do
        MailerUrlOptionsGuard.validate!(
          default_url_options: { host: "https://example.com" },
          allowed_hosts: %w(example.com),
        )
      end

    assert_includes error.message, "must not include a scheme"
  end

  test "validate! rejects host outside allow list" do
    error =
      assert_raises(MailerUrlOptionsGuard::InvalidDefaultUrlOptionsError) do
        MailerUrlOptionsGuard.validate!(
          default_url_options: { host: "sign.umaxica.app" },
          allowed_hosts: %w(localhost),
        )
      end

    assert_includes error.message, "allowed host list"
  end
end
