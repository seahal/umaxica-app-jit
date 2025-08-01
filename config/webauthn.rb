WebAuthn.configure do |config|
  # Configure allowed origins based on environment
  # This application serves multiple domains for different user types
  allowed_origins = []

  if Rails.env.development?
    allowed_origins = [
      "http://auth.org.localhost:3000",
      "http://auth.app.localhost:3000",
      "https://auth.umaxica.app",
      "https://auth.umaxica.org"
    ]
  elsif Rails.env.production?
    # Production origins from environment variables
    auth_service_url = ENV["AUTH_SERVICE_URL"]
    auth_staff_url = ENV["AUTH_STAFF_URL"]

    allowed_origins = [
      auth_service_url,
      auth_staff_url
    ].compact
  elsif Rails.env.test?
    allowed_origins = [
      "http://test.example.com",
      "http://localhost:3000",
      "http://localhost:3333"
    ]
  end

  config.allowed_origins = allowed_origins

  # Relying Party name for display purposes
  # config.rp_name = ENV.fetch("WEBAUTHN_RP_NAME", "Umaxica")

  # Configure timeout for user interaction (2 minutes)
  config.credential_options_timeout = 120_000

  # Relying Party ID - use the base domain for cross-subdomain support
  # In production, this should be the root domain (e.g., "example.com")
  # to allow credentials to work across all subdomains
  if Rails.env.production?
    # Extract base domain from service URL or use environment variable
    base_domain = ENV["WEBAUTHN_RP_ID"]
    if base_domain.blank? && ENV["WWW_SERVICE_URL"].present?
      uri = URI.parse(ENV["WWW_SERVICE_URL"])
      # Extract base domain (e.g., "example.com" from "app.example.com")
      host_parts = uri.host.split(".")
      base_domain = host_parts.length > 2 ? host_parts[-2..-1].join(".") : uri.host
    end
    config.rp_id = base_domain if base_domain.present?
  elsif Rails.env.development?
    # For development, use localhost
    config.rp_id = "localhost"
  end

  # Use base64url encoding (default, but explicit for clarity)
  config.encoding = :base64url

  # Configure supported algorithms
  # ES256 (ECDSA with SHA-256) is widely supported and recommended
  # PS256 and RS256 provide RSA alternatives
  config.algorithms = [ "ES256", "PS256", "RS256" ]
end
