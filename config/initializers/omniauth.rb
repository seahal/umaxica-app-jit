# frozen_string_literal: true

# =============================================================================
# OmniAuth Configuration
# =============================================================================
#
# Supported providers:
# - Google OAuth2: Standard OAuth2 flow with state parameter
# - Apple Sign In: Uses id_token (OIDC), POST callback
#
# Routing (OmniAuth standard):
# - Start:    POST /auth/:provider (CSRF protected via omniauth-rails_csrf_protection)
# - Callback: GET/POST /auth/:provider/callback
# - Failure:  GET/POST /auth/failure
#
# Our custom entry point:
# - GET /social/start?provider=...&intent=... -> prepares intent, redirects to /auth/:provider
#
# State Parameter:
# - All providers use state validation (via SocialAuthConcern)
# - State is stored in session[:social_auth_intent] and validated on callback
# - Apple receives state via POST body (form_post response_mode)
#
# IMPORTANT: Apple Sign In Constraints
# - Callback URL must be HTTPS with a valid domain (no localhost/IP)
# - Local development requires a tunnel (ngrok, Cloudflare Tunnel, etc.)
# - Register exactly: https://<your-domain>/auth/apple/callback in Apple Developer
# - Callback is always POST (form_post response mode)
#
# IMPORTANT: Google Cloud Console Setup
# - Register: http://localhost:3000/auth/google_oauth2/callback for local dev
# - Register: https://<your-domain>/auth/google_oauth2/callback for production
#
# =============================================================================

Rails.application.config.middleware.use OmniAuth::Builder do
  # ---------------------------------------------------------------------------
  # Google OAuth2
  # ---------------------------------------------------------------------------
  # Standard OAuth2 flow. Callback: GET /auth/google_oauth2/callback
  provider :google_oauth2,
           ENV["OMNI_AUTH_GOOGLE_CLIENT_ID"] || Rails.application.credentials.dig(:OMNI_AUTH, :GOOGLE, :CLIENT_ID),
           ENV["OMNI_AUTH_GOOGLE_CLIENT_SECRET"] || Rails.application.credentials.dig(:OMNI_AUTH, :GOOGLE, :CLIENT_SECRET),
           {
             # OmniAuth standard callback path
             callback_path: "/auth/google_oauth2/callback",
             # Request minimal scopes - we identify by provider+uid only
             scope: "openid",
             # Include access_type for refresh token (optional)
             access_type: "offline",
             # Always show account picker
             prompt: "select_account",
           }

  # ---------------------------------------------------------------------------
  # Apple Sign In
  # ---------------------------------------------------------------------------
  # Uses OIDC id_token flow. Callback: POST /auth/apple/callback
  #
  # Required credentials:
  # - CLIENT_ID: Service ID (e.g., "com.example.app.web")
  # - TEAM_ID: Apple Developer Team ID (10 chars)
  # - KEY_ID: Key ID from Apple Developer (10 chars)
  # - PRIVATE_KEY: Contents of .p8 file (including BEGIN/END markers)
  provider :apple,
           ENV["OMNI_AUTH_APPLE_CLIENT_ID"] || Rails.application.credentials.dig(:OMNI_AUTH, :APPLE, :CLIENT_ID),
           "", # Secret is derived from private key, not passed here
           {
             # OmniAuth standard callback path
             callback_path: "/auth/apple/callback",
             # Minimal scope - we only need user identifier (sub)
             scope: "email",
             team_id: ENV["OMNI_AUTH_APPLE_TEAM_ID"] || Rails.application.credentials.dig(:OMNI_AUTH, :APPLE, :TEAM_ID),
             key_id: ENV["OMNI_AUTH_APPLE_KEY_ID"] || Rails.application.credentials.dig(:OMNI_AUTH, :APPLE, :KEY_ID),
             pem: ENV["OMNI_AUTH_APPLE_PEM"] || Rails.application.credentials.dig(:OMNI_AUTH, :APPLE, :PRIVATE_KEY),
             # Apple returns response via POST (form_post)
             # State is included in POST body, not id_token
             response_mode: :form_post,
             # We handle state validation ourselves in SocialAuthConcern
             # This prevents OmniAuth's built-in validation from interfering
             # IMPORTANT: We still validate state - see SocialAuthConcern#validate_social_auth_state!
             provider_ignores_state: true,
             # Nonce for id_token replay protection (omniauth-apple handles this)
             nonce: true,
           }
end

# Only allow POST for initiating OAuth (CSRF protection via omniauth-rails_csrf_protection)
OmniAuth.config.allowed_request_methods = %i(post)

# =============================================================================
# Failure Handling
# =============================================================================
# Redirect to our custom failure endpoint.
# This uses OmniAuth standard path: /auth/failure
OmniAuth.config.on_failure =
  proc do |env|
    message = env["omniauth.error.type"]&.to_s || "unknown_error"
    strategy = env["omniauth.error.strategy"]&.name || "unknown"

    # Log the actual error for debugging (not exposed to user)
    error = env["omniauth.error"]
    if error
      Rails.logger.error(
        "[OmniAuth] Failure: strategy=#{strategy} type=#{message} " \
        "error_class=#{error.class.name} error_message=#{error.message}",
      )
    end

    # Build failure URL with query parameters (OmniAuth standard path)
    failure_path = "/auth/failure?message=#{CGI.escape(message)}&strategy=#{CGI.escape(strategy)}"

    Rack::Response.new(["302 Found"], 302, "Location" => failure_path).finish
  end
