# typed: false

require_relative "boot"

require "rails/all"
require_relative "../../shared/lib/io_keys"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Foundation
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.2

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

    # Shared directory configuration
    shared_root = File.expand_path("../../shared", __dir__)
    config.paths.add "app/models", with: "#{shared_root}/app/models", autoload: true
    config.paths.add "app/controllers", with: "#{shared_root}/app/controllers", autoload: true
    config.paths.add "app/services", with: "#{shared_root}/app/services", autoload: true
    config.autoload_paths << "#{shared_root}/app/models/concerns"
    config.autoload_paths << "#{shared_root}/app/controllers/concerns"
    config.autoload_paths << "#{shared_root}/lib"
    config.i18n.load_path += Dir["#{shared_root}/config/locales/**/*.{rb,yml}"]
  end
end
