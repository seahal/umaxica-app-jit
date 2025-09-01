# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

module CorsUtils
  # Extracts domain (and variants) from a URL string safely.
  def self.extract_domain(url)
    return [] if url.blank?

    begin
      uri = URI.parse(url)
      domains = [ uri.host ]

      # Add with and without www prefix
      if uri.host&.start_with?("www.")
        domains << uri.host.sub("www.", "")
      else
        domains << "www.#{uri.host}" if uri.host
      end

      # Add with port if specified
      if uri.port && [ 80, 443 ].exclude?(uri.port)
        domains = domains.map { |domain| "#{domain}:#{uri.port}" }
      end

      domains.compact
    rescue URI::InvalidURIError
      []
    end
  end
end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # =============================================================================
  # DEVELOPMENT CONFIGURATION
  # =============================================================================
  if Rails.env.development?
    allow do
      origins "localhost:3000", "localhost:3001", "localhost:3002",
              "127.0.0.1:3000", "127.0.0.1:3001", "127.0.0.1:3002",
              "localhost:5173", "localhost:4173" # For Vite/frontend dev servers

      resource "*",
        headers: :any,
        methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
        credentials: true,
        max_age: 86400 # 24 hours
    end
  end

  # =============================================================================
  # PRODUCTION/STAGING CONFIGURATION
  # =============================================================================

  # Corporate domain (com) - API access
  allow do
    origins ->(source, env) {
      corporate_domains = [
        ENV["WWW_CORPORATE_URL"],
        ENV["API_CORPORATE_URL"]
      ].compact.map { |url| CorsUtils.extract_domain(url) }.flatten

      corporate_domains.include?(source) ||
      (Rails.env.development? && source&.include?("localhost"))
    }

    resource "/api/com/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true,
      max_age: 3600, # 1 hour
      expose: [ "X-RateLimit-Limit", "X-RateLimit-Remaining", "X-RateLimit-Reset" ]

    resource "/auth/com/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true,
      max_age: 3600
  end

  # Service domain (app) - API access
  allow do
    origins ->(source, env) {
      service_domains = [
        ENV["WWW_SERVICE_URL"],
        ENV["API_SERVICE_URL"]
      ].compact.map { |url| CorsUtils.extract_domain(url) }.flatten

      service_domains.include?(source) ||
      (Rails.env.development? && source&.include?("localhost"))
    }

    resource "/api/app/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true,
      max_age: 3600,
      expose: [ "X-RateLimit-Limit", "X-RateLimit-Remaining", "X-RateLimit-Reset" ]

    resource "/auth/app/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true,
      max_age: 3600
  end

  # Staff domain (org) - API access
  allow do
    origins ->(source, env) {
      staff_domains = [
        ENV["WWW_STAFF_URL"],
        ENV["API_STAFF_URL"]
      ].compact.map { |url| CorsUtils.extract_domain(url) }.flatten

      staff_domains.include?(source) ||
      (Rails.env.development? && source&.include?("localhost"))
    }

    resource "/api/org/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true,
      max_age: 3600,
      expose: [ "X-RateLimit-Limit", "X-RateLimit-Remaining", "X-RateLimit-Reset" ]

    resource "/auth/org/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true,
      max_age: 3600
  end

  # Public resources - allow from any domain but limited methods
  allow do
    origins "*"

    resource "/health*",
      headers: [ "Accept", "Accept-Language", "Content-Language", "Content-Type" ],
      methods: [ :get, :head, :options ],
      credentials: false,
      max_age: 86400

    resource "/docs/*",
      headers: [ "Accept", "Accept-Language", "Content-Language", "Content-Type" ],
      methods: [ :get, :head, :options ],
      credentials: false,
      max_age: 86400

    resource "/news/*",
      headers: [ "Accept", "Accept-Language", "Content-Language", "Content-Type" ],
      methods: [ :get, :head, :options ],
      credentials: false,
      max_age: 86400
  end

  # WebAuthn/PassKey endpoints - more restrictive
  allow do
    origins ->(source, env) {
      all_domains = [
        ENV["WWW_CORPORATE_URL"],
        ENV["WWW_SERVICE_URL"],
        ENV["WWW_STAFF_URL"]
      ].compact.map { |url| CorsUtils.extract_domain(url) }.flatten

      all_domains.include?(source) ||
      (Rails.env.development? && source&.include?("localhost"))
    }

    resource "/auth/*/setting/passkeys*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options ],
      credentials: true,
      max_age: 0 # No caching for security-sensitive endpoints
  end
end

# =============================================================================
# LOGGING AND DEBUGGING
# =============================================================================

if Rails.env.development? || ENV["CORS_DEBUG"] == "true"
  Rails.application.config.after_initialize do
    Rails.logger.info "[CORS] Configured domains:"
    Rails.logger.info "[CORS] Corporate: #{ENV['WWW_CORPORATE_URL']} / #{ENV['API_CORPORATE_URL']}"
    Rails.logger.info "[CORS] Service: #{ENV['WWW_SERVICE_URL']} / #{ENV['API_SERVICE_URL']}"
    Rails.logger.info "[CORS] Staff: #{ENV['WWW_STAFF_URL']} / #{ENV['API_STAFF_URL']}"
  end
end
