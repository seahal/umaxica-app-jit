# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

# Ensure custom middleware is loaded only if present
subdomain_static_files_path = File.expand_path("../lib/subdomain_static_files.rb", __dir__)
require_relative "../lib/subdomain_static_files" if File.exist?(subdomain_static_files_path)

module Jit
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    ### Added by user
    if [ "test", "production", "development" ].include? Rails.env
      config.active_record.encryption.primary_key = Rails.application.credentials.active_record_encryption.primary_key
      config.active_record.encryption.deterministic_key = Rails.application.credentials.active_record_encryption.deterministic_key
      config.active_record.encryption.key_derivation_salt = Rails.application.credentials.active_record_encryption.key_derivation_salt
    end

    # USE UTC
    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc

    # ActiveJob
    config.active_job.queue_adapter = :karafka

    # SMS Provider Configuration
    config.sms_provider = ENV.fetch("SMS_PROVIDER", "aws_sns")
    config.aws_region = ENV.fetch("AWS_REGION", "ap-northeast-1")

    # Set UUID as default primary key for new tables
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
  end
end
