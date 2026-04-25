# typed: false
# frozen_string_literal: true

class Engine < ::Rails::Engine
  isolate_namespace Jit::Distributor

  engine_name "distributor"

  initializer "jit_distributor.view_paths" do
    ActiveSupport.on_load(:action_controller) do
      prepend_view_path Engine.root.join("app/views")
    end
  end

  # Zeitwerk mapping for flattened paths
  initializer "jit_distributor.zeitwerk_mapping" do
    autoloader = Rails.autoloaders.main
    autoloader.push_dir(root.join("app/controllers"), namespace: Jit::Distributor)
    autoloader.push_dir(root.join("app/helpers"), namespace: Jit::Distributor)
  end

  # Controllers in this engine can resolve concerns from the host app
  # through Rails' default autoloading. No additional configuration needed.
end
