# typed: false
# frozen_string_literal: true

    require "test_helper"

    class Post::Org::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV.fetch("DISTRIBUTOR_POST_ORG_URL", "docs.org.localhost")
      end

      test "returns client_id as post_org" do
        controller = Post::Org::Auth::CallbacksController.new

        assert_equal "post_org", controller.send(:oidc_client_id)
      end

      test "callback route exists" do
        assert_routing(
          { method: :get, path: "http://#{@host}/auth/callback" },
          { host: @host, controller: "jit/distributor/post/org/auth/callbacks", action: "show" },
        )
      end
    end
  end
end
