source "https://rubygems.org"
# source "https://gem.coop"

ruby "3.4.7"

# rake
gem "rake", "13.2.1"
# rack
gem "rack"
# Rails
gem "rails", "8.1.0.beta1"
# Use Postgres as the database for Active Record
gem "puma"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# Use Kredis to get higher-level data types sign_in Redis [https://github.com/rails/kredis]
gem "pg"
gem "pg_search"
gem "postgresql_cursor"
gem "fx"
gem "scenic"
# Use the Puma web server [https://github.com/puma/puma]
gem "redis"
# Kafka
gem "karafka"
gem "karafka-web"
# For CORS
gem "rack-cors"
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
# for Amazon SNS
gem "aws-sdk"
# for Active Storage
gem "google-cloud-storage", require: false
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
# pagination
gem "kaminari"
# Breadcrumbs
# gem "gretel"
# Social Login
gem "omniauth"
gem "omniauth-apple"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
# 認可 (Authorization)
gem "pundit"
gem "action_policy"
gem "rolify"
# Altanative way of Active Storage
gem "carrierwave"
# gem "view_component"
# OpenAPI
gem "rswag"
gem "ostruct"
gem "rswag-api"
gem "rswag-ui"
# JWT
gem "jwt"
#
gem "jsbundling-rails"
# for fastly cache purge
gem "fastly"
#
# gem "thruster", require: false

group :development, :test do
  # to avoid n+1 queries
  # gem "bullet"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
  # coverage
  gem "simplecov", require: false
end

group :development do
  gem "bundler-audit"
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
  #
  gem "license_finder", require: false
end
