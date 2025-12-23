require_relative "boot"

require "rails/all"

# Silence ActiveSupport::Configurable deprecation warning from omniauth-rails_csrf_protection
# Temporarily wrap $stderr to filter the specific deprecation message
class DeprecationFilter
  def initialize(original_stderr)
    @original_stderr = original_stderr
  end

  def write(message)
    # Filter out the ActiveSupport::Configurable deprecation
    msg_str = message.to_s
    return if msg_str.include?("ActiveSupport::Configurable is deprecated") ||
              msg_str.include?("You can emulate the previous behavior with")

    @original_stderr.write(message)
  end

  def puts(*messages)
    messages.each do |message|
      msg_str = message.to_s
      next if msg_str.include?("ActiveSupport::Configurable is deprecated") ||
              msg_str.include?("You can emulate the previous behavior with")

      @original_stderr.puts(message)
    end
  end

  def method_missing(method, *, &)
    @original_stderr.send(method, *, &)
  end

  def respond_to_missing?(method, include_private = false)
    @original_stderr.respond_to?(method, include_private) || super
  end
end

original_stderr = $stderr
$stderr = DeprecationFilter.new(original_stderr)

Bundler.require(*Rails.groups)

# Restore original stderr
$stderr = original_stderr

# Ensure custom middleware is loaded only if present
subdomain_static_files_path = File.expand_path("../lib/subdomain_static_files.rb", __dir__)
require_relative "../lib/subdomain_static_files" if File.exist?(subdomain_static_files_path)

module Jit
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # CommonHelper ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Add app/errors to autoload paths
    config.autoload_paths << Rails.root.join("app/errors")

    ### Added by user
    # Rack Attack Middleware
    config.middleware.use Rack::Attack
    # Active Record Encryption Configuration
    if [ "test", "production", "development" ].include? Rails.env
      config.active_record.encryption.primary_key = Rails.application.credentials.active_record_encryption.primary_key
      config.active_record.encryption.deterministic_key = Rails.application.credentials.active_record_encryption.deterministic_key
      config.active_record.encryption.key_derivation_salt = Rails.application.credentials.active_record_encryption.key_derivation_salt
    end

    # USE UTC
    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc

    # ActiveJob
    # Use Solid Queue for job processing
    config.active_job.queue_adapter = :solid_queue
    config.solid_queue.connects_to = { database: { writing: :queue, reading: :queue_replica } }

    # SMS Provider Configuration
    config.sms_provider = ENV.fetch("SMS_PROVIDER", "aws_sns")
    config.aws_region = ENV.fetch("AWS_REGION", "ap-northeast-1")

    # Load translations from nested locale directories (e.g., config/locales/jp/**/*.yml)
    config.i18n.load_path += Rails.root.glob("config/locales/**/*.{rb,yml}")

    # Set UUID as default primary key for new tables
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
  end
end
