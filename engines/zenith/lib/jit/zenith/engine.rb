# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    class Engine < ::Rails::Engine
      isolate_namespace Jit::Zenith

      engine_name "zenith"

      initializer "jit_zenith.view_paths" do
        ActiveSupport.on_load(:action_controller) do
          prepend_view_path Engine.root.join("app/views")
        end
      end

      # Zeitwerk mapping for flattened paths
      initializer "jit_zenith.zeitwerk_mapping" do
        autoloader = Rails.autoloaders.main
        autoloader.push_dir(root.join("app/controllers"), namespace: Jit::Zenith)
        autoloader.push_dir(root.join("app/helpers"), namespace: Jit::Zenith)
      end

      # Controllers in this engine can resolve concerns from the host app
      # through Rails' default autoloading. No additional configuration needed.
    end
  end
end
