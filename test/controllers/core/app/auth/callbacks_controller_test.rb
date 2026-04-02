# typed: false
# frozen_string_literal: true

require "test_helper"

class Core::App::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")
  end

  test "returns client_id as main_app" do
    controller = Core::App::Auth::CallbacksController.new

    assert_equal "main_app", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "core/app/auth/callbacks", action: "show" },
    )
  end
end
