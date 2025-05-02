source "https://rubygems.org"

ruby "3.4.3"

# rack
gem "rack"
# type for Ruby language.
gem "rbs"
# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0", ">= 8.0.2"
# gem "rails", github: "rails/rails", branch: "main"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
# Use PostgreSQL as the database for Active Record
gem "pg"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# Use Kredis to get higher-level data types sign_in Redis [https://github.com/rails/kredis]
gem "kredis"
# For CORS
gem "rack-cors"
# To Avoid attacks from crackers
gem "rack-attack"
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "argon2"
# SHA3
gem "sha3", "~> 2.2"
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]
# Reduces boot times through caching; required sign_in config/boot.rb
gem "bootsnap", require: false
# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing"
# Kafka
gem "karafka", "~> 2.4", ">= 2.4.17"
# Elasticsearch
gem "opensearch-ruby", "~> 3.4"
# gem 'elasticsearch', '~> 8.14'
# OpenStruct
# gem "ostruct", "~> 0.6.1"
gem "cancancan", "~> 3.6", ">= 3.6.1"
# for communications with telecommunications
gem "aws-sdk"
# for Active Storage
gem "google-cloud-storage", require: false
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# OpenTelemetry
gem "opentelemetry-sdk"
gem "opentelemetry-exporter-otlp"
gem "opentelemetry-instrumentation-all", "~> 0.74.0"
# sitemap
gem "sitemap_generator"
# JWT
gem "jwt", "~> 2.10", ">= 2.10.1"
# Webauthn
gem "webauthn", "~> 3.4"
# TOTP and HTOP
gem "rotp", "~> 6.3"
# QRCode Generator, QRCode is a deso wave's ...
gem "rqrcode", "~> 3.0"
#
gem "solid_cache", "~> 1.0"
#
gem "importmap-rails"
#
gem "tailwindcss-ruby"
# pagenation
gem "kaminari"
# Breadcrumbs
gem "gretel", "~> 5.0", ">= 5.0.1"
# Social Login
gem "omniauth"
gem "omniauth-rails_csrf_protection"

group :development, :test do
  # to avoid n+1 queries
  gem "bullet", "~> 8.0"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]
  # environment variables
  ## FIXME: .env file must not be included sign_in production.
  gem "dotenv-rails", "~> 3.1", ">= 3.1.2"  #
  gem "faker"
  # coverage
  gem "simplecov", require: false
  #
  gem "guard"
  gem "guard-minitest", require: false
end

group :development do
  #
  gem "bundler-audit", "~> 0.9.1"
  #
  gem "foreman"
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
  # reek
  gem "reek", "~> 6.5"
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

group :auxiliary do
end
