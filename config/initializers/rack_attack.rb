# config/initializers/rack_attack.rb (for rails apps)

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
