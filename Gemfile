# frozen_string_literal: true

source "https://rubygems.org"
# source "https://gem.coop"

ruby "4.0.1"

# Rake
gem "rake"
# Rack
gem "rack"
# Rails
# Tracking the main branch for Rails 8.1 features.
# Once Rails 8.1 has a stable gem release, switch to:
#   gem "rails", "~> 8.1.0"
# or the stable maintenance branch:
#   gem "rails", github: "rails/rails", branch: "8-1-stable"
gem "rails", github: "rails/rails", branch: "main"
# Web server
gem "puma"
# JSON APIs
gem "jbuilder"
# Use OpenStruct
gem "ostruct"
# Database
gem "pg"
gem "neighbor"
gem "strong_migrations"
# Redis
gem "redis"
# CORS
gem "rack-cors"
# DoS protection
gem "rack-attack"
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
gem "aws-sdk-sns"
gem "aws-sdk-connect"
gem "aws-sdk-polly"
# Asset pipeline
gem "propshaft"
# OpenTelemetry
gem "opentelemetry-sdk", require: false
gem "opentelemetry-exporter-otlp", require: false
gem "opentelemetry-instrumentation-all", require: false
# Sitemap
gem "sitemap_generator"
# TOTP
gem "rotp"
# QR code generation
gem "rqrcode"
# Solid Cache
gem "solid_cache"
# Solid Queue
gem "solid_queue"
gem "mission_control-jobs"
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
# Fastly cache purge
gem "fastly"
# HTML head tags
gem "meta-tags"
# ID generation
gem "nanoid"
# Authentication
gem "pundit"
# billing
gem "stripe"
# sorbet
gem "sorbet-runtime"

group :development, :test do
  # Test coverage
  gem "simplecov", require: false
  # Minitest mock (extracted from minitest 6.0+)
  gem "minitest-mock"
  # Slow test profiling
  gem "test-prof"
  # Postgres performance viewer
  gem "pghero"
  # N+1 query detector
  # gem "bullet"
  gem "prosopite"
  gem "pg_query"
  # Database consistency checks
  gem "database_consistency", require: false
  # ckecker for open api
  gem "committee-rails"
  gem "debride"
  # type
  gem "tapioca", require: false
end

group :development do
  # Debugging
  gem "debug", platforms: %i( mri windows )
  gem "sorbet"
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
  # gem "spring"
  gem "brakeman", require: false
  # web-console 4.2.1 is incompatible with Rails main (ActionDispatch::RemoteIp API change)
  # gem "web-console"
  # RuboCop
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-thread_safety", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-i18n", require: false
  gem "rubocop-rubycw", require: false
  # ERB lint
  gem "erb_lint", require: false
  # Annotate models, routes, fixtures, etc.
  gem "annotaterb"
  # License finder
  gem "license_finder", require: false
  # Ruby LSP
  gem "ruby-lsp"
  # Code quality tools
  gem "flog", require: false
  gem "flay", require: false
  gem "reek", require: false
  # ERD diagrams
  gem "rails-erd", require: false
  gem "railroady", require: false
  gem "rails-mermaid_erd", require: false
  # Security
  gem "bundler-audit", require: false
end
