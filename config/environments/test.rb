# typed: false
# frozen_string_literal: true

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

require Rails.root.join("lib/strict_environment_config")
require Rails.root.join("lib/mailer_url_options_guard")

ENV["DEFAULT_TEST"] ||= "{test,engines/*/test}/**/*_test.rb"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Show full error reports.
  config.consider_all_requests_local = true
  config.cache_store = :null_store

  # Raise exceptions directly so tests fail at the first rescuable error.
  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  # config.active_storage.service = :test

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use test adapter for ActiveJob in test environment
  config.active_job.queue_adapter = :test

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "example.com" }
  MailerUrlOptionsGuard.validate!(
    default_url_options: config.action_mailer.default_url_options,
    allowed_hosts: %w(example.com),
  )

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  StrictEnvironmentConfig.apply!(config)

  # The following lines were added by me.
  # Bullet, a gem to help you avoid N+1 queries and unused eager loading.
  # Rails.application.configure do
  #   config.after_initialize do
  #     Bullet.enable = true
  #     Bullet.bullet_logger = true
  #     Bullet.raise = true # raise an error if n+1 query occurs
  #   end
  # end

  # ci seed up.
  if ENV["CI"]
    config.assets.compile = false
    config.assets.gzip = false
  end

  # SMS Provider Configuration - Use test provider in test environment
  config.sms_provider = "test"

  # Use PostgreSQL unlogged tables for faster test performance
  ActiveSupport.on_load(:active_record_postgresqladapter) do
    self.create_unlogged_tables = true
  end
end
