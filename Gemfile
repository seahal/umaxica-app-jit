# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.4'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '7.2.0.beta3'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use PostgreSQL as the database for Active Record
gem 'pg', '~> 1.3', '>= 1.3.3'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'hiredis', '~> 0.6.3'
gem 'redis', '~> 5.2'

# For Cache store @ Redis
gem 'redis-actionpack'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
gem 'kredis'

# For CORS
gem 'rack-cors'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"
gem 'argon2', '~> 2.3'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# FIXME: i am wondering that using aws's s3.
gem 'aws-sdk-s3', require: false

# Kafka
gem 'karafka', '~> 2.4', '>= 2.4.7'

# Elasticsearch
gem 'elasticsearch', '~> 8.14'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
     gem 'rubocop', require: false
  gem 'rails_best_practices', '~> 1.23', '>= 1.23.2'
  gem 'bundler-audit', '~> 0.9.1'
  gem 'churn', '~> 1.0', '>= 1.0.8'
  gem 'flay', '~> 2.13', '>= 2.13.3'
  gem 'guard'
  gem 'guard-brakeman'
  gem 'guard-minitest'
  gem 'guard-rubocop'
  gem 'rails-erd', '~> 1.7', '>= 1.7.2'
  gem 'reek', '~> 6.3'
  gem 'rubocop-rails', require: false
  gem 'web-console'
  gem 'bullet', '~> 7.2'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end
