# typed: false
# frozen_string_literal: true

module Jit
  module Security
    # Centralized key resolution for Cloudflare Turnstile.
    # Priority: Rails credentials (flat key) -> Rails credentials (nested key) -> ENV -> nil
    class TurnstileConfig
      KEYS = {
        default_site_key: "CLOUDFLARE_TURNSTILE_SITE_KEY",
        default_secret_key: "CLOUDFLARE_TURNSTILE_SECRET_KEY",
        stealth_site_key: "CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY",
        stealth_secret_key: "CLOUDFLARE_TURNSTILE_SECRET_STEALTH_KEY",
      }.freeze

      class << self
        def default_site_key
          fetch("CLOUDFLARE_TURNSTILE_SITE_KEY")
        end

        def default_secret_key
          fetch("CLOUDFLARE_TURNSTILE_SECRET_KEY")
        end

        def stealth_site_key
          fetch("CLOUDFLARE_TURNSTILE_SITE_STEALTH_KEY")
        end

        def stealth_secret_key
          fetch("CLOUDFLARE_TURNSTILE_SECRET_STEALTH_KEY")
        end

        private

        def fetch(key_name)
          value = credential(key_name)
          return value if value.present?

          value = ENV[key_name]
          return value if value.present?

          nil
        end

        def credential(key_name)
          return unless defined?(Rails)

          # Try flat key first (e.g., CLOUDFLARE_TURNSTILE_SITE_KEY)
          value = Rails.application.credentials[key_name.to_sym]
          return value if value.present?

          # Fallback: try nested key (e.g., CLOUDFLARE -> TURNSTILE_SITE_KEY)
          nested_key = key_name.to_s.delete_prefix("CLOUDFLARE_").to_sym
          Rails.application.credentials.dig(:CLOUDFLARE, nested_key)
        end
      end
    end
  end
end
