# typed: false
# frozen_string_literal: true

require "test_helper"

class Docs::Com::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("DOCS_CORPORATE_URL", "docs.com.localhost")
  end

  test "returns client_id as docs_com" do
    controller = Docs::Com::Auth::CallbacksController.new

    assert_equal "docs_com", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "docs/com/auth/callbacks", action: "show" },
    )
  end
end
