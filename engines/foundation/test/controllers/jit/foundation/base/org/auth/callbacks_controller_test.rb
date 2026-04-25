# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    require "test_helper"

    class Jit::Foundation::Base::Org::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV.fetch("FOUNDATION_BASE_ORG_URL", "base.org.localhost")
      end

      test "returns client_id as core_org" do
        controller = Jit::Foundation::Base::Org::Auth::CallbacksController.new

        assert_equal "core_org", controller.send(:oidc_client_id)
      end

      test "callback route exists" do
        assert_routing(
          { method: :get, path: "http://#{@host}/auth/callback" },
          { host: @host, controller: "jit/foundation/base/org/auth/callbacks", action: "show" },
        )
      end
    end
  end
end
