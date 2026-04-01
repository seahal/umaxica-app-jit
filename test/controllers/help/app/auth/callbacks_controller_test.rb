# typed: false
# frozen_string_literal: true

require "test_helper"

class Help::App::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("HELP_SERVICE_URL", "help.app.localhost")
  end

  test "returns client_id as help_app" do
    controller = Help::App::Auth::CallbacksController.new

    assert_equal "help_app", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "help/app/auth/callbacks", action: "show" },
    )
  end
end
