# typed: false
# frozen_string_literal: true

class Engine < ::Rails::Engine
  isolate_namespace Jit::Foundation

  engine_name "foundation"

  initializer "jit_foundation.view_paths" do
    ActiveSupport.on_load(:action_controller) do
      prepend_view_path Engine.root.join("app/views")
    end
  end

  # Zeitwerk mapping for flattened paths
  initializer "jit_foundation.zeitwerk_mapping" do
    autoloader = Rails.autoloaders.main
    autoloader.push_dir(root.join("app/controllers"), namespace: Jit::Foundation)
    autoloader.push_dir(root.join("app/helpers"), namespace: Jit::Foundation)
  end

  # Controllers in this engine can resolve concerns from the host app
  # through Rails' default autoloading. No additional configuration needed.
end
