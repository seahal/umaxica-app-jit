source "https://rubygems.org"
# source "https://gem.coop"

ruby "4.0.0-preview3"

# rake
gem "rake"
# rack
gem "rack"
# Rails
# gem "rails"
gem "rails", github: "rails/rails", branch: "main"
# Use Postgres as the database for Active Record
gem "puma"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# Use Kredis to get higher-level data types sign_in Redis [https://github.com/rails/kredis]
gem "pg"
# Use the Puma web server [https://github.com/puma/puma]
gem "redis"
# For CORS
gem "rack-cors"
# For DOS attack
gem "rack-attack"
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt"
gem "argon2"
# SHA3
gem "sha3"
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]
# Reduces boot times through caching; required sign_in config/boot.rb
gem "bootsnap", require: false
# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "shrine"
gem "image_processing"
# for Amazon SNS
gem "aws-sdk-sns"
gem "aws-sdk-connect"
gem "aws-sdk-polly"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# OpenTelemetry
gem "opentelemetry-sdk"
gem "opentelemetry-exporter-otlp"
gem "opentelemetry-instrumentation-all"
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
# Solid Queue
gem "solid_queue"
# pagination
gem "kaminari"
# Social Login
gem "omniauth"
gem "omniauth-apple"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
# OpenAPI
gem "ostruct"
gem "rswag"
gem "rswag-api"
gem "rswag-ui"
# JWT
gem "jwt"
# Hotwire
gem "turbo-rails"
gem "stimulus-rails"
gem "importmap-rails"
# Tailwind CSS
gem "tailwindcss-rails"
# for fastly cache purge
gem "fastly"
# easty to write tags in head.
gem "meta-tags"
# use surrogate key for pk of db.
gem "nanoid"
# Authentication
gem "pundit"
gem "view_component"

group :development, :test do
  # to avoid n+1 queries
  # gem "bullet"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
  # coverage
  gem "simplecov", require: false
  # minitest mock (extracted from minitest 6.0+)
  gem "minitest-mock"
  # for IntelliJ IDEA
  # gem 'ruby-debug-ide'
end

group :development do
  gem "bundler-audit"
  gem "foreman"
  gem "yard"
  # Preview email in the default browser instead of sending it.
  gem "letter_opener"
  # Live Reload
  gem "rails_live_reload"
  gem "hotwire-livereload"
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem "rack-mini-profiler"
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "brakeman", require: false
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  # rubocop
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-thread_safety", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-i18n", require: false
  gem "rubocop-rubycw", require: false
  # erb linter
  gem "erb_lint", require: false
  # annotate models, routes, fixtures, and others [https://github.com/ctran/annotate_models]
  gem "annotaterb"
  gem "license_finder", require: false
  gem "ruby-lsp"
  gem "reek"
  gem "churn"
  gem "flog"
  gem "rails-erd"
end
