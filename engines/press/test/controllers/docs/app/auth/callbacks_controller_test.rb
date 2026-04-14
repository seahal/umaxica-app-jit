# typed: false
# frozen_string_literal: true

require "test_helper"

class Docs::App::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("DOCS_SERVICE_URL", "docs.app.localhost")
  end

  test "returns client_id as docs_app" do
    controller = Docs::App::Auth::CallbacksController.new

    assert_equal "docs_app", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "docs/app/auth/callbacks", action: "show" },
    )
  end
end
