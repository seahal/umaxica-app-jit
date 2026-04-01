# typed: false
# frozen_string_literal: true

require "test_helper"

class Help::Com::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("HELP_CORPORATE_URL", "help.com.localhost")
  end

  test "returns client_id as help_com" do
    controller = Help::Com::Auth::CallbacksController.new

    assert_equal "help_com", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "help/com/auth/callbacks", action: "show" },
    )
  end
end
