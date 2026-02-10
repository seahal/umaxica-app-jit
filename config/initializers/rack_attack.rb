# frozen_string_literal: true

#
# === Rack::Attack Rate Limiting Configuration ===
#
# This file configures 5 focused throttles:
# 1. Global ceiling - IP-based safety fuse (600 req/min)
# 2. Auth endpoints - Sign-in/up/verification (POST and GET forms) (30 req/min)
# 3. Token refresh - Strictest limit for token refresh (10 req/min)
# 4. API ceiling - General API rate limit (120 req/min)
# 5. API heavy - Strict limit for expensive operations (30 req/min)
#
# === Development Testing ===
#
# To manually test rate limiting in development:
#   export RACK_ATTACK_DEV_LOW_LIMIT=1   # Scale limits to 1-2 requests for easy testing
#   export RACK_ATTACK_DEBUG=1           # Enable debug logging (shows rule matches)
#   bin/rails server
#
# Then use curl to trigger throttles:
#   curl -i http://localhost:3000/edge/v1/csrf  # Hit twice to see 429
#
# === Test Environment ===
#
# Rack::Attack is disabled by default in test env. Tests that verify throttling
# must explicitly enable it and use an isolated cache store.
#

require "ipaddr"

class Rack::Attack
  ############################################################
  # 0) Cache store configuration
  ############################################################
  Rack::Attack.cache.store =
    if Rails.env.test?
      ActiveSupport::Cache::MemoryStore.new
    else
      ActiveSupport::Cache::RedisCacheStore.new(
        url: ENV.fetch("VALKEY_RACK_ATTACK_URL"),
        namespace: "rack_attack",
        reconnect_attempts: 3,
        timeout: 1.0,
      )
    end

  ############################################################
  # 1) Disable throttling in test env (tests can override)
  ############################################################
  if Rails.env.test?
    Rack::Attack.enabled = false
  end

  ############################################################
  # 2) Trusted proxies (required behind CDN/ALB)
  ############################################################
  unless Rails.env.test?
    Rails.application.config.action_dispatch.trusted_proxies = [
      IPAddr.new("10.0.0.0/8"),
      IPAddr.new("172.16.0.0/12"),
      IPAddr.new("192.168.0.0/16"),
    ]
  end

  ############################################################
  # 3) Custom Request class (uses ActionDispatch remote_ip)
  ############################################################
  class Request < ::Rack::Request
    def ip
      ActionDispatch::Request.new(env).remote_ip
    end
  end

  ############################################################
  # 4) Path patterns (frozen for thread safety)
  ############################################################

  # Heavy/expensive API operations
  HEAVY_PATHS = [
    %r{\A/api/search},
    %r{\A/api/reports},
    %r{\A/api/exports},
    %r{\A/documents/export},
  ].freeze

  # Auth write endpoints (POST sign-in/up/verification)
  AUTH_WRITE_PATHS = [
    %r{\A/in/(email|passkey|secret)\z},                    # login
    %r{\A/in/mfa/(totp|passkey)\z},                        # MFA challenge
    %r{\A/up/emails\z},                                     # signup email
    %r{\A/up/telephones\z},                                 # signup telephone
    %r{\A/up/telephones/resend\z},                         # resend code
    %r{\A/verification/(passkey|totp|emails)\z},           # verification submit
  ].freeze

  # Auth form GET endpoints (HTML display)
  AUTH_HTML_GET_PATHS = [
    %r{\A/in/new\z},                                        # sign-in form
    %r{\A/up/new\z},                                        # sign-up form
    %r{\A/verification/(passkey|totp|emails)/new\z}, # verification forms
  ].freeze

  # Token refresh endpoint (strictest limit)
  TOKEN_REFRESH_PATH = %r{\A/edge/v1/token/refresh\z}.freeze

  # General API paths
  API_PATHS = %r{\A/api/}.freeze

  ############################################################
  # 5) Helper methods
  ############################################################

  # Returns tenant identifier from host
  def self.tenant_key(req)
    req.host.to_s.downcase.delete_suffix(".")
  end

  # Adjusts limits for development testing
  # Set RACK_ATTACK_DEV_LOW_LIMIT=1 to scale all limits to 1-2 for easy manual testing
  def self.throttle_limit(base)
    if Rails.env.development? && ENV["RACK_ATTACK_DEV_LOW_LIMIT"] == "1"
      # Scale to 1-2 requests for easy testing
      [1, (base / 100.0).ceil].max
    else
      base
    end
  end

  # Debug logging helper
  def self.debug_log(message)
    return unless Rails.env.development? && ENV["RACK_ATTACK_DEBUG"] == "1"

    Rails.logger.info("[Rack::Attack] #{message}")
  end

  ############################################################
  # 6) Throttle rules (5 total)
  ############################################################

  # Rule 1: Global ceiling (IP-based safety fuse)
  throttle("global/ip", limit: proc { throttle_limit(600) }, period: 1.minute) do |req|
    debug_log("Rule global/ip checking: #{req.ip}")
    req.ip
  end

  # Rule 2: Auth endpoints (sign-in/up/verification - both POST and GET forms)
  throttle("auth/tenant_ip", limit: proc { throttle_limit(30) }, period: 1.minute) do |req|
    # Match POST operations to auth endpoints
    if req.post? && AUTH_WRITE_PATHS.any? { |re| re.match?(req.path) }
      key = "#{tenant_key(req)}:#{req.ip}"
      debug_log("Rule auth/tenant_ip matched POST: #{req.path} -> #{key}")
      next key
    end

    # Match GET requests to HTML auth forms (to prevent form scraping/enumeration)
    if req.get? && AUTH_HTML_GET_PATHS.any? { |re| re.match?(req.path) }
      key = "#{tenant_key(req)}:#{req.ip}"
      debug_log("Rule auth/tenant_ip matched GET: #{req.path} -> #{key}")
      next key
    end

    nil
  end

  # Rule 3: Token refresh (strictest - high-value endpoint)
  throttle("token_refresh/tenant_ip", limit: proc { throttle_limit(10) }, period: 1.minute) do |req|
    next unless req.post? && TOKEN_REFRESH_PATH.match?(req.path)

    key = "#{tenant_key(req)}:#{req.ip}"
    debug_log("Rule token_refresh/tenant_ip matched: #{req.path} -> #{key}")
    key
  end

  # Rule 4: API ceiling (general API traffic)
  throttle("api/tenant_ip", limit: proc { throttle_limit(120) }, period: 1.minute) do |req|
    next unless API_PATHS.match?(req.path)

    key = "#{tenant_key(req)}:#{req.ip}"
    debug_log("Rule api/tenant_ip matched: #{req.path} -> #{key}")
    key
  end

  # Rule 5: Heavy API operations (expensive queries/exports)
  throttle("api_heavy/tenant_ip", limit: proc { throttle_limit(30) }, period: 1.minute) do |req|
    next unless HEAVY_PATHS.any? { |re| re.match?(req.path) }

    key = "#{tenant_key(req)}:#{req.ip}"
    debug_log("Rule api_heavy/tenant_ip matched: #{req.path} -> #{key}")
    key
  end

  ############################################################
  # 7) Throttled response (HTML vs JSON)
  ############################################################
  self.throttled_responder =
    lambda do |request|
      # Determine response format based on Accept header
      accept = request.env["HTTP_ACCEPT"].to_s

      if accept.include?("text/html")
        # HTML response (plain text for simplicity)
        [
          429,
          {
            "Content-Type" => "text/plain",
            "Retry-After" => "60",
          },
          [I18n.t("errors.rate_limit.exceeded") + "\n"],
        ]
      else
        # JSON response (default for API)
        [
          429,
          {
            "Content-Type" => "application/json",
            "Retry-After" => "60",
          },
          [{ error: "rate_limited", message: "Too many requests" }.to_json],
        ]
      end
    end
end

##############################################################
# 8) Audit log (only on throttle events)
##############################################################
ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _id, payload|
  next unless payload[:match_type] == :throttle

  req = payload[:request]

  # Emit Rails event for downstream subscribers
  Rails.event.notify(
    "rack_attack.throttled",
    rule: payload[:name],
    match_type: payload[:match_type],
    host: req&.host,
    ip: req&.ip,
    path: req&.path,
  )

  # Debug logging (safe - no sensitive data)
  if Rails.env.development? && ENV["RACK_ATTACK_DEBUG"] == "1"
    Rails.logger.warn(
      "[Rack::Attack] THROTTLED: rule=#{payload[:name]} " \
      "host=#{req&.host} ip=#{req&.ip} path=#{req&.path}",
    )
  end
end
