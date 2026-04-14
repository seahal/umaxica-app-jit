# frozen_string_literal: true

source "https://rubygems.org"
# source "https://gem.coop"

ruby "3.4.9"

# Rake
gem "rake"
# Rack
gem "rack"
# Boundary enforcement for granular modular architecture
gem "packwerk", require: false
# Rails
#   gem "rails", "~> 8.1.0"
gem "rails", github: "rails/rails", branch: "main"
# Rails Engines for four-deployment architecture
# - signature: Auth/Passkey/OIDC (permanent URLs)
# - world: Global BFF/Dashboard (flexible evolution)
# - station: Regional operations (per-region deploy)
# - press: Content delivery (closed network via CF VPN)
gem "jit-world", path: "engines/world" # FIXME: jit_global
gem "jit-signature", path: "engines/signature" # FIXME: rename jit_visa
gem "jit-station", path: "engines/station" # FIXME: jit_regional
gem "jit-press", path: "engines/press" # FIXME: jit_publisher
# Web server
gem "puma"
gem "falcon"
# Push Notification
gem "action_push_native"
# Database
gem "pg"
gem "strong_migrations"
# Redis
gem "redis"
# Typed Redis structures
gem "kredis"
# Timeout
gem "rack-timeout", group: %i(development production)
# CORS
gem "rack-cors"
# Password hashing
gem "argon2"
gem "bcrypt"
# SHA3
gem "sha3"
# Time zone data for Windows
gem "tzinfo-data", platforms: %i(windows jruby)
# Boot caching
gem "bootsnap", require: false
# File uploads and processing
gem "shrine"
gem "image_processing"
# AWS SDKs
gem "aws-sdk-sns" # for sms delivery
gem "aws-sdk-secretsmanager" # for secret_key_base rotation
# Asset pipeline
gem "propshaft"
# OpenTelemetry
gem "opentelemetry-sdk", require: false
gem "opentelemetry-exporter-otlp", require: false
gem "opentelemetry-instrumentation-all", require: false
# search
gem "pg_search"
# TOTP
gem "rotp"
# QR code generation
gem "rqrcode"
# Solid Cache
gem "solid_cache"
# Solid Queue
gem "solid_queue"
gem "mission_control-jobs"
gem "mission_control-servers"
# Pagination
gem "pagy"
# WebAuthn (FIDO2)
gem "webauthn"
# Social login
gem "omniauth"
gem "omniauth-apple"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
# JWT
gem "jwt"
# Hotwire
gem "turbo-rails"
gem "stimulus-rails"
gem "importmap-rails"
# Tailwind CSS
gem "tailwindcss-rails"
# HTML head tags
gem "meta-tags"
# ID generation
gem "nanoid"
# OpenStruct
gem "ostruct"
# Authentication
gem "action_policy"
# billing
gem "stripe"
# SQL exploration
gem "blazer"
gem "sentry-ruby"
gem "sentry-rails"
# Data maintenance tasks with web UI (works with SolidQueue)
gem "maintenance_tasks"
# Multi-channel notification framework
gem "noticed"

group :development, :test do
  # Test coverage
  gem "simplecov", require: false
  gem "simplecov-lcov", require: false
  # Minitest mock (extracted from minitest 6.0+)
  gem "minitest-mock"
  # Slow test profiling
  gem "test-prof"
  # N+1 query detector
  gem "prosopite"
  gem "pg_query"
  # Database consistency checks
  gem "database_consistency", require: false
  # ckecker for open api
  gem "committee-rails"
  gem "debride"
  # type
  gem "tapioca", require: false
  # sorbet
  gem "rack-livereload"
end

group :development do
  # Debugging
  gem "debug", platforms: %i( mri windows )
  gem "foreman"
  gem "yard"
  # Preview email in the browser instead of sending it
  gem "letter_opener"
  # Live reload
  gem "hotwire-spark"
  gem "rails_live_reload"
  # Performance profiling
  gem "rack-mini-profiler"
  # Speed up commands on slow machines / big apps
  gem "brakeman", require: false
  # RuboCop
  gem "rubocop", require: false
  gem "rubocop-ast", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-thread_safety", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-i18n", require: false
  gem "rubocop-rubycw", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-sorbet", require: false
  # ERB lint
  gem "erb_lint", require: false
  # Annotate models, routes, fixtures, etc.
  gem "annotaterb"
  # Code quality tools
  gem "flog", require: false
  gem "flay", require: false
  gem "reek", require: false
  # ERD diagrams
  gem "rails-mermaid_erd", require: false
  # Security
  gem "bundler-audit", require: false
  # Git hooks manager
  gem "lefthook", require: false
end
