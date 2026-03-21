# typed: false
# frozen_string_literal: true

require "test_helper"

class Docs::Org::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("DOCS_STAFF_URL", "docs.org.localhost")
  end

  test "returns client_id as docs_org" do
    controller = Docs::Org::Auth::CallbacksController.new

    assert_equal "docs_org", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "docs/org/auth/callbacks", action: "show" },
    )
  end
end
