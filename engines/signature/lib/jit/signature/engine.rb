# typed: false
# frozen_string_literal: true

module Jit
  module Signature
    class Engine < ::Rails::Engine
      # NOTE: Do NOT use isolate_namespace. Controller class names remain unchanged
      # (Sign::App::*Controller etc.) to avoid mass-renaming hundreds of files.

      engine_name "jit_signature"

      # Controllers in this engine can resolve concerns from the host app
      # through Rails' default autoloading. No additional configuration needed.
    end
  end
end
