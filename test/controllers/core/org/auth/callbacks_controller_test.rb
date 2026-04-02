# typed: false
# frozen_string_literal: true

require "test_helper"

class Core::Org::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("MAIN_STAFF_URL", "main.org.localhost")
  end

  test "returns client_id as main_org" do
    controller = Core::Org::Auth::CallbacksController.new

    assert_equal "main_org", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "core/org/auth/callbacks", action: "show" },
    )
  end
end
