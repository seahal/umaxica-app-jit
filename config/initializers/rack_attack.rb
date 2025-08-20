# config/initializers/rack_attack.rb (for rails apps)

# Configure Redis as cache store for Rack::Attack
Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
)

# Enable/disable Rack::Attack based on environment
Rack::Attack.enabled = Rails.env.production? || ENV["RACK_ATTACK_ENABLED"] == "true"

# Configure throttled response
Rack::Attack.throttled_responder = lambda do |req|
  retry_after = req.env["rack.attack.match_data"][:period] - (Time.current.to_i % req.env["rack.attack.match_data"][:period])
  [
    429,
    {
      "Content-Type" => "application/json",
      "Retry-After" => retry_after.to_s,
      "X-RateLimit-Limit" => req.env["rack.attack.match_data"][:limit].to_s,
      "X-RateLimit-Remaining" => "0",
      "X-RateLimit-Reset" => (Time.current + retry_after).to_i.to_s
    },
    [ { error: "Rate limit exceeded. Try again later.", retry_after: retry_after }.to_json ]
  ]
end

# =============================================================================
# SAFELISTS
# =============================================================================

# Provided that trusted users use an HTTP request header named APIKey
Rack::Attack.safelist("mark any authenticated access safe") do |request|
  # Requests are allowed if the return value is truthy
  request.env["HTTP_APIKEY"] == ENV["RACK_ATTACK_API_KEY"]
end

# Always allow requests from localhost
# (blocklist & throttles are skipped)
Rack::Attack.safelist("allow from localhost") do |req|
  # Requests are allowed if the return value is truthy
  "127.0.0.1" == req.ip || "::1" == req.ip
end

# Allow health check endpoints
Rack::Attack.safelist("allow health checks") do |req|
  req.path.start_with?("/health") || req.path == "/robots.txt" || req.path == "/favicon.ico"
end

# =============================================================================
# BLOCKLISTS
# =============================================================================

# Block suspicious requests
Rack::Attack.blocklist("block suspicious requests") do |req|
  # Block requests with suspicious user agents
  suspicious_agents = [
    /bot/i, /crawl/i, /spider/i, /scrape/i,
    /curl/i, /wget/i, /python/i, /java/i,
    /scanner/i, /exploit/i, /hack/i
  ]

  user_agent = req.user_agent.to_s.downcase
  suspicious_agents.any? { |pattern| user_agent.match?(pattern) } &&
    !req.env["HTTP_APIKEY"] && # Allow if has valid API key
    !req.path.start_with?("/health") # Allow health checks
end

# Block requests with malicious payloads
Rack::Attack.blocklist("block malicious payloads") do |req|
  malicious_patterns = [
    /select.*from/i, /union.*select/i, /drop.*table/i,
    /<script/i, /javascript:/i, /eval\(/i,
    /\.\.\//, /etc\/passwd/, /proc\/self/,
    /%00/, /%2e%2e/, /%252e/
  ]

  query_string = req.query_string.to_s
  body = req.body.read.to_s rescue ""
  req.body.rewind if req.body.respond_to?(:rewind)

  malicious_patterns.any? do |pattern|
    query_string.match?(pattern) || body.match?(pattern)
  end
end

# =============================================================================
# THROTTLES
# =============================================================================

# Throttle requests by IP (general)
Rack::Attack.throttle("requests by ip", limit: 300, period: 5.minutes) do |req|
  req.ip unless req.path.start_with?("/assets", "/health")
end

# Throttle API requests more strictly
Rack::Attack.throttle("api requests by ip", limit: 100, period: 1.hour) do |req|
  req.ip if req.path.start_with?("/api/")
end

# Throttle authentication attempts
Rack::Attack.throttle("auth requests by ip", limit: 10, period: 1.hour) do |req|
  req.ip if req.path.include?("auth") && req.post?
end

# Throttle password reset requests
Rack::Attack.throttle("password reset by ip", limit: 5, period: 1.hour) do |req|
  req.ip if req.path.include?("password") && req.post?
end

# Throttle registration attempts
Rack::Attack.throttle("registration by ip", limit: 3, period: 1.day) do |req|
  req.ip if req.path.include?("registration") && req.post?
end

# Throttle requests by email parameter (for auth endpoints)
Rack::Attack.throttle("auth requests by email", limit: 5, period: 1.hour) do |req|
  if req.path.include?("auth") && req.post?
    email = req.params["email"].presence ||
            req.params.dig("user", "email").presence ||
            req.params.dig("staff", "email").presence
    email.to_s.downcase if email
  end
end

# =============================================================================
# CUSTOM TRACKS (for monitoring/alerting)
# =============================================================================

# Track suspicious activity for monitoring
Rack::Attack.track("suspicious activity") do |req|
  req.user_agent.to_s.include?("scanner") ||
  req.query_string.to_s.include?("union") ||
  req.path.include?("../")
end

# Track failed authentication attempts
Rack::Attack.track("failed auth") do |req|
  req.path.include?("auth") && req.post? && req.env["HTTP_X_FORWARDED_FOR"].present?
end

# =============================================================================
# CUSTOM CACHE KEYS
# =============================================================================

# Use more specific cache keys for different request types
Rack::Attack.throttle("detailed requests by ip", limit: 1000, period: 1.hour) do |req|
  # Skip assets and health checks
  next if req.path.start_with?("/assets", "/health", "/favicon", "/robots")

  # Create cache key with IP and request type
  "#{req.ip}:#{req.path.split('/')[1..2].join(':')}"
end

# =============================================================================
# LOGGING AND NOTIFICATIONS
# =============================================================================

ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, req|
  Rails.logger.warn "[Rack::Attack] #{req.env['rack.attack.match_type']}: #{req.ip} #{req.request_method} #{req.fullpath}"

  # You can add additional logging or alerting here
  # Example: send to monitoring service, Slack, etc.
end
