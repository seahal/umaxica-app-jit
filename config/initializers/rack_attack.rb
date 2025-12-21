# config/initializers/rack_attack.rb

# frozen_string_literal: true

require "ipaddr"

# class Rack::Attack
#   ############################################################
#   # 0) Rack::Attack dedicated Redis (required)
#   ############################################################
#   Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
#     url: ENV.fetch("VALKEY_RACK_ATTACK_URL"),
#     namespace: "rack_attack",
#     reconnect_attempts: 3,
#     timeout: 1.0
#   )


#   ############################################################
#   # 2) trusted proxies (required behind CDN/ALB)
#   ############################################################
#   Rack::Attack.trusted_proxies = [
#     IPAddr.new("10.0.0.0/8"),
#     IPAddr.new("172.16.0.0/12"),
#     IPAddr.new("192.168.0.0/16")
#   ]

#   ############################################################
#   # 3) tenant_key (multi-domain support)
#   ############################################################
#   def self.tenant_key(req)
#     req.host.to_s.downcase.delete_suffix(".")
#   end

#   ############################################################
#   # 4) global ceiling (safety fuse)
#   ############################################################
#   throttle("req/global/ip", limit: 600, period: 1.minute) do |req|
#     req.ip
#   end

#   ############################################################
#   # 5) tenant fairness (noisy neighbor guard)
#   ############################################################
#   throttle("req/tenant/ip", limit: 300, period: 1.minute) do |req|
#     "#{tenant_key(req)}:#{req.ip}"
#   end

#   ############################################################
#   # 6) expensive paths (only what's needed)
#   ############################################################
#   HEAVY_PATHS = [
#     %r{\A/api/search},
#     %r{\A/api/reports},
#     %r{\A/api/exports},
#     %r{\A/documents/export}
#   ].freeze

#   throttle("req/heavy/tenant/ip", limit: 60, period: 1.minute) do |req|
#     next unless HEAVY_PATHS.any? { |re| re.match?(req.path) }
#     "#{tenant_key(req)}:#{req.ip}"
#   end

#   ############################################################
#   # 7) per-auth user (optional, fewer false positives)
#   ############################################################
#   throttle("req/tenant/user", limit: 120, period: 1.minute) do |req|
#     user = req.env["current_user_key"].to_s
#     next if user.empty?
#     "#{tenant_key(req)}:#{user}"
#   end

#   ############################################################
#   # 8) blocked response (simple)
#   ############################################################
#   self.throttled_response = lambda do |env|
#     req = Rack::Request.new(env)
#     [
#       429,
#       { "Content-Type" => "application/json" },
#       [ { error: "rate_limited", host: req.host }.to_json ]
#     ]
#   end
# end

# ##############################################################
# # 9) audit log (recommended)
# ##############################################################
# ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _id, payload|
#   req = payload[:request]
#   Rails.logger.warn(
#     event: "rack_attack",
#     rule: payload[:name],
#     match_type: payload[:match_type],
#     host: req&.host,
#     ip: req&.ip,
#     path: req&.path
#   )
# end
