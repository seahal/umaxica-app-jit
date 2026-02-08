# frozen_string_literal: true

require "test_helper"
require "jit/security/turnstile_config"

module Jit
  module Security
    class TurnstileConfigTest < ActiveSupport::TestCase
      # Pure unit test - no database/fixtures needed
      self.use_transactional_tests = false
      self.fixture_table_names = []

      # -- default keys ---------------------------------------------------

      test "default_site_key returns credential when present" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SITE_KEY, "cred-site") do
          assert_equal "cred-site", TurnstileConfig.default_site_key
        end
      end

      test "default_site_key falls back to ENV when credential is absent" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SITE_KEY, nil) do
          with_env("CLOUDFLARE_TURNSTILE_SITE_KEY" => "env-site") do
            assert_equal "env-site", TurnstileConfig.default_site_key
          end
        end
      end

      test "default_secret_key returns credential when present" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SECRET_KEY, "cred-secret") do
          assert_equal "cred-secret", TurnstileConfig.default_secret_key
        end
      end

      test "default_secret_key falls back to ENV when credential is absent" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SECRET_KEY, nil) do
          with_env("CLOUDFLARE_TURNSTILE_SECRET_KEY" => "env-secret") do
            assert_equal "env-secret", TurnstileConfig.default_secret_key
          end
        end
      end

      # -- stealth keys ---------------------------------------------------

      test "stealth_site_key returns credential when present" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY, "cred-stealth-site") do
          assert_equal "cred-stealth-site", TurnstileConfig.stealth_site_key
        end
      end

      test "stealth_site_key falls back to ENV when credential is absent" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY, nil) do
          with_env("CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY" => "env-stealth-site") do
            assert_equal "env-stealth-site", TurnstileConfig.stealth_site_key
          end
        end
      end

      test "stealth_secret_key returns credential when present" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SECRET_STEALTH_KEY, "cred-stealth-secret") do
          assert_equal "cred-stealth-secret", TurnstileConfig.stealth_secret_key
        end
      end

      test "stealth_secret_key falls back to ENV when credential is absent" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SECRET_STEALTH_KEY, nil) do
          with_env("CLOUDFLARE_TURNSTILE_SECRET_STEALTH_KEY" => "env-stealth-secret") do
            assert_equal "env-stealth-secret", TurnstileConfig.stealth_secret_key
          end
        end
      end

      # -- nested credential fallback -------------------------------------

      test "default_site_key falls back to nested credential when flat is absent" do
        fake_creds = fake_credentials(flat: {}, nested: { TURNSTILE_SITE_KEY: "nested-site" })
        Rails.application.stub(:credentials, fake_creds) do
          with_env("CLOUDFLARE_TURNSTILE_SITE_KEY" => nil) do
            assert_equal "nested-site", TurnstileConfig.default_site_key
          end
        end
      end

      test "default_secret_key falls back to nested credential when flat is absent" do
        fake_creds = fake_credentials(flat: {}, nested: { TURNSTILE_SECRET_KEY: "nested-secret" })
        Rails.application.stub(:credentials, fake_creds) do
          with_env("CLOUDFLARE_TURNSTILE_SECRET_KEY" => nil) do
            assert_equal "nested-secret", TurnstileConfig.default_secret_key
          end
        end
      end

      test "flat credential takes priority over nested credential" do
        fake_creds = fake_credentials(
          flat: { CLOUDFLARE_TURNSTILE_SITE_KEY: "flat-site" },
          nested: { TURNSTILE_SITE_KEY: "nested-site" },
        )
        Rails.application.stub(:credentials, fake_creds) do
          assert_equal "flat-site", TurnstileConfig.default_site_key
        end
      end

      # -- edge cases -----------------------------------------------------

      test "returns nil when neither credential nor ENV is set" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY, nil) do
          with_env("CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY" => nil) do
            assert_nil TurnstileConfig.stealth_site_key
          end
        end
      end

      test "empty string credential is treated as absent (present? check)" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY, "") do
          with_env("CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY" => "env-fallback") do
            assert_equal "env-fallback", TurnstileConfig.stealth_site_key
          end
        end
      end

      test "empty string ENV is treated as absent (present? check)" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY, nil) do
          with_env("CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY" => "") do
            assert_nil TurnstileConfig.stealth_site_key
          end
        end
      end

      test "credential takes priority over ENV" do
        stub_credential(:CLOUDFLARE_TURNSTILE_SECRET_STEALTH_KEY, "from-cred") do
          with_env("CLOUDFLARE_TURNSTILE_SECRET_STEALTH_KEY" => "from-env") do
            assert_equal "from-cred", TurnstileConfig.stealth_secret_key
          end
        end
      end

      private

      # Stub a single flat credential key, with nested keys returning nil
      def stub_credential(key, value)
        flat = value.nil? || value == "" ? (value == "" ? { key => value } : {}) : { key => value }
        fake_creds = fake_credentials(flat: flat, nested: {})
        Rails.application.stub(:credentials, fake_creds) do
          yield
        end
      end

      # Build a fake credentials object with controllable flat and nested keys
      # flat: { CLOUDFLARE_TURNSTILE_SITE_KEY: "value" }
      # nested: { TURNSTILE_SITE_KEY: "value" } (looked up via dig(:CLOUDFLARE, key))
      def fake_credentials(flat: {}, nested: {})
        creds = Object.new
        creds.define_singleton_method(:[]) { |key| flat[key] }
        creds.define_singleton_method(:dig) do |*args|
          if args.length == 2 && args[0] == :CLOUDFLARE
            nested[args[1]]
          end
        end
        creds
      end

      # Temporarily set ENV vars, restoring originals afterwards
      def with_env(vars)
        originals = {}
        vars.each do |k, v|
          originals[k] = ENV[k]
          if v.nil?
            ENV.delete(k)
          else
            ENV[k] = v
          end
        end
        yield
      ensure
        originals.each do |k, v|
          if v.nil?
            ENV.delete(k)
          else
            ENV[k] = v
          end
        end
      end
    end
  end
end
