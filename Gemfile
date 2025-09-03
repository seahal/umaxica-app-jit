source "https://rubygems.org"

ruby "3.4.5"

# rake
gem "rake"
# rack
gem "rack"
# type for Ruby language.
gem "rbs"
# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0", ">= 8.0.2"
# Use PostgreSQL as the database for Active Record
gem "pg"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# Use Kredis to get higher-level data types sign_in Redis [https://github.com/rails/kredis]
gem "hiredis-client"
gem "redis"
# For CORS
gem "rack-cors"
# To Avoid attacks from crackers
gem "rack-attack"
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "argon2"
# SHA3
gem "sha3"
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]
# Reduces boot times through caching; required sign_in config/boot.rb
gem "bootsnap", require: false
# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing"
# Kafka
gem "karafka"
gem "karafka-web"
# Elasticsearch
gem "opensearch-ruby"
# for Amazon SNS
gem "aws-sdk"
# for Active Storage
gem "google-cloud-storage", require: false
# google cloud
gem "google-cloud-kms"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# OpenTelemetry
gem "opentelemetry-exporter-otlp"
gem "opentelemetry-instrumentation-all"
gem "opentelemetry-sdk"
# sitemap
gem "sitemap_generator"
# Webauthn for fido2
gem "webauthn"
# TOTP and HTOP
gem "rotp"
# QRCode Generator, QRCode is a deso wave's ...
gem "rqrcode"
# Solid Cache
gem "solid_cache"
# pagenation
gem "kaminari"
# Breadcrumbs
gem "gretel"
# Social Login
gem "omniauth"
gem "omniauth-apple"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
# 認可 (Authorization)
gem "pundit"
gem "rolify"
# Altanative way of Active Storage
gem "carrierwave"
gem "jsbundling-rails"
gem "view_component"
# OpenAPI
gem "rswag"
gem "ostruct", "~> 0.6.3"
gem "rswag-api"
gem "rswag-ui"
# JWT
gem "jwt"


group :development, :test do
  # to avoid n+1 queries
  gem "bullet"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
  # coverage
  gem "simplecov", require: false
end

group :development do
  gem "bundler-audit", "~> 0.9.1"
  gem "foreman"
  gem "yard"
  # Preview email in the default browser instead of sending it.
  gem "letter_opener"
  # Live Reload
  gem "rails_live_reload"
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem "rack-mini-profiler"
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "brakeman", require: false
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  # rubocop
  gem "rubocop", require: false
  gem "rubocop-rails-omakase", require: false
  # erb linter
  gem "erb_lint", require: false
  # annotate models, routes, fixtures, and others [https://github.com/ctran/annotate_models]
  gem "annotaterb"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
