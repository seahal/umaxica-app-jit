# frozen_string_literal: true

require "ipaddr"

class Rack::Attack
  ############################################################
  # 0) Rack::Attack dedicated Redis (required)
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
  # 1) disable throttling in test env
  ############################################################
  if Rails.env.test?
    Rack::Attack.enabled = false
  end

  ############################################################
  # 2) trusted proxies (required behind CDN/ALB)
  ############################################################
  unless Rails.env.test?
    Rails.application.config.action_dispatch.trusted_proxies = [
      IPAddr.new("10.0.0.0/8"),
      IPAddr.new("172.16.0.0/12"),
      IPAddr.new("192.168.0.0/16"),
    ]
  end

  class Request < ::Rack::Request
    def ip
      ActionDispatch::Request.new(env).remote_ip
    end
  end

  ############################################################
  # 6) expensive paths (only what's needed)
  ############################################################
  HEAVY_PATHS = [
    %r{\A/api/search},
    %r{\A/api/reports},
    %r{\A/api/exports},
    %r{\A/documents/export},
  ].freeze
  ############################################################
  # 3) tenant_key (multi-domain support)
  ############################################################
  def self.tenant_key(req)
    req.host.to_s.downcase.delete_suffix(".")
  end

  ############################################################
  # 4) global ceiling (safety fuse)
  ############################################################
  throttle("req/global/ip", limit: 600, period: 1.minute) do |req|
    req.ip
  end

  ############################################################
  # 5) tenant fairness (noisy neighbor guard)
  ############################################################
  throttle("req/tenant/ip", limit: 300, period: 1.minute) do |req|
    "#{tenant_key(req)}:#{req.ip}"
  end

  throttle("req/heavy/tenant/ip", limit: 60, period: 1.minute) do |req|
    next unless HEAVY_PATHS.any? { |re| re.match?(req.path) }

    "#{tenant_key(req)}:#{req.ip}"
  end

  ############################################################
  # 7) per-auth user (optional, fewer false positives)
  ############################################################
  throttle("req/tenant/user", limit: 120, period: 1.minute) do |req|
    user = req.env["current_user_key"].to_s
    next if user.empty?

    "#{tenant_key(req)}:#{user}"
  end

  ############################################################
  # 8) blocked response (simple)
  ############################################################
  self.throttled_responder =
    lambda do |request|
      [
        429,
        { "Content-Type" => "application/json" },
        [{ error: "rate_limited", host: request.host }.to_json],
      ]
    end
end

##############################################################
# 9) audit log (recommended)
##############################################################
ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]
  Rails.event.notify(
    "rack_attack.throttled",
    rule: payload[:name],
    match_type: payload[:match_type],
    host: req&.host,
    ip: req&.ip,
    path: req&.path,
  )
end
