# typed: false
# frozen_string_literal: true

require_relative "../../../test/test_helper"

# For integration tests in this engine, include both main app routes and engine routes
ActiveSupport.on_load(:action_dispatch_integration_test) do
  include Rails.application.routes.url_helpers
  include Jit::Station::Engine.routes.url_helpers
end
