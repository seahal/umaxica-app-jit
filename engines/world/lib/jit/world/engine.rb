# typed: false
# frozen_string_literal: true

module Jit
  module World
    class Engine < ::Rails::Engine
      # NOTE: Do NOT use isolate_namespace. Controller class names remain unchanged
      # (Apex::App::*Controller etc.) to avoid mass-renaming hundreds of files.

      engine_name "jit_world"

      # Controllers in this engine can resolve concerns from the host app
      # through Rails' default autoloading. No additional configuration needed.
    end
  end
end
