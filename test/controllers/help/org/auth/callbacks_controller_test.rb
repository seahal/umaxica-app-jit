# typed: false
# frozen_string_literal: true

require "test_helper"

class Help::Org::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("HELP_STAFF_URL", "help.org.localhost")
  end

  test "returns client_id as help_org" do
    controller = Help::Org::Auth::CallbacksController.new

    assert_equal "help_org", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "help/org/auth/callbacks", action: "show" },
    )
  end
end
