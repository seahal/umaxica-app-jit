# typed: false
# frozen_string_literal: true

class Engine < ::Rails::Engine
  isolate_namespace Jit::Identity

  engine_name "identity"

  initializer "jit_identity.view_paths" do
    ActiveSupport.on_load(:action_controller) do
      prepend_view_path Engine.root.join("app/views")
    end
  end

  # Zeitwerk mapping for flattened paths
  initializer "jit_identity.zeitwerk_mapping" do
    autoloader = Rails.autoloaders.main
    autoloader.push_dir(root.join("app/controllers"), namespace: Jit::Identity)
    autoloader.push_dir(root.join("app/helpers"), namespace: Jit::Identity)
  end

  # Controllers in this engine can resolve concerns from the host app
  # through Rails' default autoloading. No additional configuration needed.
end
