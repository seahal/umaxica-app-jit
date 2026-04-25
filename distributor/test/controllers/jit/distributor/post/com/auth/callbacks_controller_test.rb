# typed: false
# frozen_string_literal: true

    require "test_helper"

    class Post::Com::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV.fetch("DISTRIBUTOR_POST_COM_URL", "docs.com.localhost")
      end

      test "returns client_id as post_com" do
        controller = Post::Com::Auth::CallbacksController.new

        assert_equal "post_com", controller.send(:oidc_client_id)
      end

      test "callback route exists" do
        assert_routing(
          { method: :get, path: "http://#{@host}/auth/callback" },
          { host: @host, controller: "jit/distributor/post/com/auth/callbacks", action: "show" },
        )
      end
    end
  end
end
