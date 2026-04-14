# typed: false
# frozen_string_literal: true

# Include cross-engine URL helpers in all controllers and views.
# This allows any controller or view to call route helpers from any engine
# (e.g., visa_app_root_url from a world engine controller) with automatic
# host injection from ENV variables.

require Rails.root.join("lib/cross_engine_url_helpers").to_s

ActiveSupport.on_load(:action_controller) do
  include CrossEngineUrlHelpers
end

ActiveSupport.on_load(:action_view) do
  include CrossEngineUrlHelpers
end
