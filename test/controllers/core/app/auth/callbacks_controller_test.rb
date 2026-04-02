# typed: false
# frozen_string_literal: true

require "test_helper"

class Core::App::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("CORE_SERVICE_URL", "ww.app.localhost")
  end

<<<<<<< HEAD
  test "returns client_id as core_app" do
=======
  test "returns client_id as main_app" do
>>>>>>> 98bd02f0f ([CheckPoint] renamimg from main to core.)
    controller = Core::App::Auth::CallbacksController.new

    assert_equal "core_app", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "core/app/auth/callbacks", action: "show" },
    )
  end
end
