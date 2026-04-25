# typed: false
# frozen_string_literal: true

    require "test_helper"

    class Base::Com::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV.fetch("FOUNDATION_BASE_COM_URL", "base.com.localhost")
      end

      test "returns client_id as core_com" do
        controller = Base::Com::Auth::CallbacksController.new

        assert_equal "core_com", controller.send(:oidc_client_id)
      end

      test "callback route exists" do
        assert_routing(
          { method: :get, path: "http://#{@host}/auth/callback" },
          { host: @host, controller: "jit/foundation/base/com/auth/callbacks", action: "show" },
        )
      end
    end
  end
end
