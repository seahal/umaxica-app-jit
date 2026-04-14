# typed: false
# frozen_string_literal: true

require "test_helper"

module Jit
  module Security
    class TurnstileConfigTest < ActiveSupport::TestCase
      test "KEYS contains expected environment variable names" do
        assert_equal "CLOUDFLARE_TURNSTILE_VISIBLE_SITE_KEY", TurnstileConfig::KEYS[:visible_site_key]
        assert_equal "CLOUDFLARE_TURNSTILE_VISIBLE_SECRET_KEY", TurnstileConfig::KEYS[:visible_secret_key]
        assert_equal "CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY", TurnstileConfig::KEYS[:stealth_site_key]
        assert_equal "CLOUDFLARE_TURNSTILE_SECRET_STEALTH_KEY", TurnstileConfig::KEYS[:stealth_secret_key]
      end

      test "KEYS is frozen" do
        assert_predicate TurnstileConfig::KEYS, :frozen?
      end

      test "visible_site_key returns nil when Rails is not defined" do
        # Simulate Rails not being defined by temporarily undefining it
        rails = Object.send(:remove_const, :Rails) if defined?(Rails)
        begin
          assert_nil TurnstileConfig.visible_site_key
        ensure
          # Restore Rails constant
          Object.const_set(:Rails, rails) if rails
        end
      end

      test "visible_secret_key returns nil when credential is not set" do
        Rails.app.creds.stub(:option, nil) do
          assert_nil TurnstileConfig.visible_secret_key
        end
      end

      test "stealth_site_key returns nil when credential is not set" do
        Rails.app.creds.stub(:option, nil) do
          assert_nil TurnstileConfig.stealth_site_key
        end
      end

      test "stealth_secret_key returns nil when credential is not set" do
        Rails.app.creds.stub(:option, nil) do
          assert_nil TurnstileConfig.stealth_secret_key
        end
      end

      test "enabled? returns true when ENV is not set" do
        ENV.delete("CLOUDFLARE_TURNSTILE_ENABLED")

        assert_predicate TurnstileConfig, :enabled?
      end

      test "enabled? returns true when ENV is empty" do
        ENV["CLOUDFLARE_TURNSTILE_ENABLED"] = ""

        assert_predicate TurnstileConfig, :enabled?
      end

      test "enabled? returns true for truthy values" do
        %w(1 true yes on).each do |value|
          ENV["CLOUDFLARE_TURNSTILE_ENABLED"] = value

          assert_predicate TurnstileConfig, :enabled?, "expected #{value} to be truthy"
        end
      end

      test "enabled? returns false for falsy values" do
        %w(0 false no off).each do |value|
          ENV["CLOUDFLARE_TURNSTILE_ENABLED"] = value

          assert_not TurnstileConfig.enabled?, "expected #{value} to be falsy"
        end
      end

      test "enabled? handles whitespace in ENV value" do
        ENV["CLOUDFLARE_TURNSTILE_ENABLED"] = "  false  "

        assert_not TurnstileConfig.enabled?
      end

      test "enabled? handles case-insensitive ENV value" do
        ENV["CLOUDFLARE_TURNSTILE_ENABLED"] = "FALSE"

        assert_not TurnstileConfig.enabled?
      end

      test "visible_site_key returns value from credentials" do
        Rails.app.creds.stub(:option, "test-site-key") do
          assert_equal "test-site-key", TurnstileConfig.visible_site_key
        end
      end

      test "visible_secret_key returns value from credentials" do
        Rails.app.creds.stub(:option, "test-secret-key") do
          assert_equal "test-secret-key", TurnstileConfig.visible_secret_key
        end
      end

      test "stealth_site_key returns value from credentials" do
        Rails.app.creds.stub(:option, "test-stealth-site-key") do
          assert_equal "test-stealth-site-key", TurnstileConfig.stealth_site_key
        end
      end

      test "stealth_secret_key returns value from credentials" do
        Rails.app.creds.stub(:option, "test-stealth-secret-key") do
          assert_equal "test-stealth-secret-key", TurnstileConfig.stealth_secret_key
        end
      end
    end
  end
end
