# typed: false
# frozen_string_literal: true

require "test_helper"

class Core::Org::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("CORE_STAFF_URL", "ww.org.localhost")
  end

<<<<<<< HEAD
  test "returns client_id as core_org" do
=======
  test "returns client_id as main_org" do
>>>>>>> 98bd02f0f ([CheckPoint] renamimg from main to core.)
    controller = Core::Org::Auth::CallbacksController.new

    assert_equal "core_org", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "core/org/auth/callbacks", action: "show" },
    )
  end
end
