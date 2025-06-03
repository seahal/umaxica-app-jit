WebAuthn.configure do |config|
  # Configure allowed origins based on environment
  # This application serves multiple domains for different user types
  allowed_origins = []

  if Rails.env.development?
    allowed_origins = [
      "http://localhost:3000",
      "http://127.0.0.1:3000",
      "http://localhost:3333",
      "http://127.0.0.1:3333"
    ]
  elsif Rails.env.production?
    # Production origins from environment variables
    corporate_url = ENV["WWW_CORPORATE_URL"]
    service_url = ENV["WWW_SERVICE_URL"]
    staff_url = ENV["WWW_STAFF_URL"]

    allowed_origins = [ corporate_url, service_url, staff_url ].compact
  elsif Rails.env.test?
    allowed_origins = [
      "http://test.example.com",
      "http://localhost:3000"
    ]
  end

  config.allowed_origins = allowed_origins

  # Relying Party name for display purposes
  config.rp_name = ENV.fetch("WEBAUTHN_RP_NAME", "Umaxica")

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
