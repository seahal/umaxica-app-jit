# typed: false
# frozen_string_literal: true

require "test_helper"
require "jit/security/turnstile_config"

module Jit
  module Security
    class TurnstileConfigTest < ActiveSupport::TestCase
      # Pure unit test - no database/fixtures needed
      self.use_transactional_tests = false
      self.fixture_table_names = []

      # -- visible keys ---------------------------------------------------

      test "visible_site_key returns value from creds" do
        stub_creds_option(:CLOUDFLARE_TURNSTILE_VISIBLE_SITE_KEY, "cred-site") do
          assert_equal "cred-site", TurnstileConfig.visible_site_key
        end
      end

      test "visible_secret_key returns value from creds" do
        stub_creds_option(:CLOUDFLARE_TURNSTILE_VISIBLE_SECRET_KEY, "cred-secret") do
          assert_equal "cred-secret", TurnstileConfig.visible_secret_key
        end
      end

      # -- stealth keys ---------------------------------------------------

      test "stealth_site_key returns value from creds" do
        stub_creds_option(:CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY, "cred-stealth-site") do
          assert_equal "cred-stealth-site", TurnstileConfig.stealth_site_key
        end
      end

      test "stealth_secret_key returns value from creds" do
        stub_creds_option(:CLOUDFLARE_TURNSTILE_SECRET_STEALTH_KEY, "cred-stealth-secret") do
          assert_equal "cred-stealth-secret", TurnstileConfig.stealth_secret_key
        end
      end

      # -- edge cases -----------------------------------------------------

      test "returns nil when creds returns nil" do
        stub_creds_option(:CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY, nil) do
          assert_nil TurnstileConfig.stealth_site_key
        end
      end

      private

      # Stub Rails.app.creds.option for a specific key
      def stub_creds_option(key, value)
        fake_creds = Object.new
        fake_creds.define_singleton_method(:option) do |k, **|
          (k == key) ? value : nil
        end
        fake_creds.define_singleton_method(:require) do |k|
          (k == key) ? value : raise("Missing credential: #{k}")
        end

        Rails.app.stub(:creds, fake_creds) do
          yield
        end
      end
    end
  end
end
