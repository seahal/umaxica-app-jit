# typed: false
# frozen_string_literal: true

require_relative "../../../lib/test_helper"

# For integration tests in this engine, include both main app routes and engine routes
ActiveSupport.on_load(:action_dispatch_integration_test) do
  include Rails.application.routes.url_helpers
  include Jit::Zenith::Engine.routes.url_helpers
end
