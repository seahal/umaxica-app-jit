# frozen_string_literal: true

#
# === Rack::Attack Rate Limiting Configuration ===
#
# Rack::Attack acts as a minimal last-resort safety fuse.
# Primary perimeter controls live at CDN/WAF.
#
# Throttle rules:
# 1. Global IP ceiling (600 req/min)
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

class Rack::Attack
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

  Rack::Attack.enabled = false if Rails.env.test?

  class Request < ::Rack::Request
    def ip
      ActionDispatch::Request.new(env).remote_ip
    end
  end

  def self.throttle_limit(base)
    if Rails.env.development? && ENV["RACK_ATTACK_DEV_LOW_LIMIT"] == "1"
      [1, (base / 100.0).ceil].max
    else
      base
    end
  end

  def self.debug_log(message)
    return unless Rails.env.development? && ENV["RACK_ATTACK_DEBUG"] == "1"

    Rails.logger.info("[Rack::Attack] #{message}")
  end

  throttle("global/ip", limit: proc { throttle_limit(600) }, period: 1.minute) do |req|
    debug_log("Rule global/ip checking: #{req.ip}")
    req.ip
  end

  self.throttled_responder =
    lambda do |request|
      rule = request.env["rack.attack.matched"] || "global/ip"
      headers = {
        "X-RateLimit-Layer" => "rack-attack",
        "X-RateLimit-Rule" => rule,
        "Retry-After" => "60",
      }

      accept = request.env["HTTP_ACCEPT"].to_s
      message = I18n.t("errors.rate_limit.exceeded")

      if accept.include?("text/html")
        [
          429,
          headers.merge("Content-Type" => "text/plain"),
          ["#{message}\n"],
        ]
      else
        [
          429,
          headers.merge("Content-Type" => "application/json"),
          [{ error: "rate_limited", rule: rule, message: message }.to_json],
        ]
      end
    end
end

ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
  request = payload[:request]
  next unless request

  rule = request.env["rack.attack.matched"] || payload[:name] || "unknown"
  match_type = request.env["rack.attack.match_type"] || payload[:match_type] || :throttle

  Rails.event.notify(
    "rack_attack.throttled",
    rule: rule,
    match_type: match_type,
    host: request.host,
    ip: request.ip,
    path: request.path,
  )

  if Rails.env.development? && ENV["RACK_ATTACK_DEBUG"] == "1"
    Rails.logger.warn(
      "[Rack::Attack] THROTTLED: rule=#{rule} match_type=#{match_type} " \
      "host=#{request.host} ip=#{request.ip} path=#{request.path}",
    )
  end
end
