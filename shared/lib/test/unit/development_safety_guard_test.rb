# typed: false
# frozen_string_literal: true

require "test_helper"
require "development_safety_guard"

class DevelopmentSafetyGuardTest < ActiveSupport::TestCase
  test "allowed_hosts keeps public hosts disabled by default" do
    hosts = DevelopmentSafetyGuard.allowed_hosts(env: {})

    assert_includes hosts, "localhost"
    assert_includes hosts, "sign.app.localhost"
    assert_not_includes hosts, "sign.umaxica.app"
  end

  test "allowed_hosts includes public hosts when explicitly enabled" do
    hosts = DevelopmentSafetyGuard.allowed_hosts(env: { "ALLOW_PUBLIC_DEV_HOSTS" => "1" })

    assert_includes hosts, "sign.umaxica.app"
    assert_includes hosts, "sign.umaxica.com"
    assert_includes hosts, "sign.umaxica.org"
  end

  test "mailer stays in test mode by default" do
    env = {}

    assert_equal :test, DevelopmentSafetyGuard.mailer_delivery_method(env:)
    assert_not DevelopmentSafetyGuard.perform_deliveries?(env:)
  end

  test "mailer can opt in to smtp explicitly" do
    env = { "ALLOW_DEVELOPMENT_SMTP" => "1" }

    assert_equal :smtp, DevelopmentSafetyGuard.mailer_delivery_method(env:)
    assert DevelopmentSafetyGuard.perform_deliveries?(env:)
  end

  test "sms provider test is always accepted" do
    assert_nil DevelopmentSafetyGuard.validate_sms_provider!(sms_provider: "test", env: {})
  end

  test "live sms provider is rejected by default" do
    error =
      assert_raises(DevelopmentSafetyGuard::UnsafeConfigurationError) do
        DevelopmentSafetyGuard.validate_sms_provider!(sms_provider: "aws_sns", env: {})
      end

    assert_includes error.message, "ALLOW_LIVE_SMS_IN_DEVELOPMENT=1"
  end

  test "live sms provider can opt in explicitly" do
    env = { "ALLOW_LIVE_SMS_IN_DEVELOPMENT" => "1" }

    assert_nil DevelopmentSafetyGuard.validate_sms_provider!(sms_provider: "aws_sns", env:)
  end
end
