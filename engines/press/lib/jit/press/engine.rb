# typed: false
# frozen_string_literal: true

module Jit
  module Press
    class Engine < ::Rails::Engine
      # NOTE: Do NOT use isolate_namespace. Controller class names remain unchanged
      # (Docs::App::*Controller etc.) to avoid mass-renaming hundreds of files.

      engine_name "jit_press"

      # Controllers in this engine can resolve concerns from the host app
      # through Rails' default autoloading. No additional configuration needed.
    end
  end
end
