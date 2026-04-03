# typed: false
# frozen_string_literal: true

module Jit
  module Local
    class Engine < ::Rails::Engine
      # NOTE: Do NOT use isolate_namespace yet. It will be introduced in a future
      # phase after controllers are moved and stabilised. For now, the engine
      # shares the host app's namespace so that existing controller class names
      # (Core::App::RootsController etc.) work without renaming.

      engine_name "jit_local"

      initializer "jit_local.autoload_host_concerns" do |app|
        # Let engine controllers resolve concerns defined in the host app.
        # This is a no-op when host app already autoloads these paths, but
        # makes the dependency explicit.
        engine_concerns = root.join("app", "controllers", "concerns")
        app.config.autoload_paths << engine_concerns.to_s if engine_concerns.exist?
      end
    end
  end
end
