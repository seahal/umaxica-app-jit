# typed: false
# frozen_string_literal: true

if defined?(Rack::Timeout)
  # Rack::Timeout is automatically included by its Railtie for Rails apps.
  # By default it sets service_timeout to 15s, and wait_timeout to 30s.
  # To change these defaults, use ENV variables (e.g. RACK_TIMEOUT_SERVICE_TIMEOUT)
  # or require "rack/timeout/base" in Gemfile and configure middleware manually.

  # Elevate Rack::Timeout's own log level to WARN to prevent spamming
  # standard info logs with verbose timeout tracking.
  Rack::Timeout::Logger.level = Logger::WARN
end
