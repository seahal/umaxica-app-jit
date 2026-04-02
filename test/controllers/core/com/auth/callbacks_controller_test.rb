# typed: false
# frozen_string_literal: true

require "test_helper"

class Core::Com::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("MAIN_CORPORATE_URL", "main.com.localhost")
  end

  test "returns client_id as core_com" do
    controller = Core::Com::Auth::CallbacksController.new

    assert_equal "core_com", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "core/com/auth/callbacks", action: "show" },
    )
  end
end
