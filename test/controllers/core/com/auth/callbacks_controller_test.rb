# typed: false
# frozen_string_literal: true

require "test_helper"

class Core::Com::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("CORE_CORPORATE_URL", "ww.com.localhost")
  end

<<<<<<< HEAD
  test "returns client_id as core_com" do
=======
  test "returns client_id as main_com" do
>>>>>>> 98bd02f0f ([CheckPoint] renamimg from main to core.)
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
